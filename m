From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: netlink attributes for IPv6 tunneling
Date: Wed, 30 Sep 2015 13:18:40 -0700
Message-ID: <CAEP_g=_OWHD8AuO5t3aTEJVNDHihpjzfz29ppoE1Ownm8PgRJw@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com> <ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
 <CAEP_g=-oijtUY1fD7AqK5PndCAt85uEF1Gh0yqbqz0u3-bPcRg@mail.gmail.com> <20150930092850.09b71dff@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:32852 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932630AbbI3UTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:19:02 -0400
Received: by lahh2 with SMTP id h2so60274559lah.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 13:19:00 -0700 (PDT)
In-Reply-To: <20150930092850.09b71dff@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 12:28 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 29 Sep 2015 20:05:00 -0700, Jesse Gross wrote:
>> This appears to me to be a bug in the existing code.
>> ovs_tunnel_get_egress_info() as a general mechanism is still in use
>> and should work with both the old and new configuration methods.
>
> It's currently used only from the compat layer (the API that the user
> space that is unaware of lwtunnels use).

Yes but that is a bug. From the perspective of the intended use of
this function, I don't think there is any difference between compat
and non-compat users.

> I don't understand what it would be good for with lwtunnel based
> tunnels. The metadata_dst is created in the validate_and_copy_set_tun
> function (net/openvswitch/flow_netlink.c) and used to specify egress
> encapsulation metadata. The ovs_tunnel_get_egress_info function is not
> needed.

This function is used to report back information that is the result of
the encapsulation process, such as the UDP source port chosen. Take a
look at net/openvswitch/actions.c:output_userspace(), particularly the
OVS_USERSPACE_ATTR_EGRESS_TUN_PORT case.
