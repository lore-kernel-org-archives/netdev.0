From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: report features supported by the
 kernel datapath
Date: Fri, 9 Oct 2015 15:06:33 -0700
Message-ID: <CAEP_g=9LMhjEn5X+9J8KDdqVxLBNiCjKGBG_a-_aCYWHwDBy3Q@mail.gmail.com>
References: <f035dbc85f4fb7e8c8691801849a9db286154bde.1444312374.git.jbenc@redhat.com>
 <CAEP_g=-pgG6yhGsbvbdrJdAK3VXX1a+8c-wRkHuRte0=2Byg2w@mail.gmail.com>
 <20151009092453.GB18316@pox.localdomain> <20151009114646.2ee66f3b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:35677 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbJIWGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 18:06:54 -0400
Received: by lbwr8 with SMTP id r8so94271912lbw.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 15:06:53 -0700 (PDT)
In-Reply-To: <20151009114646.2ee66f3b@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 9, 2015 at 2:46 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 9 Oct 2015 11:24:53 +0200, Thomas Graf wrote:
>> On 10/08/15 at 03:40pm, Jesse Gross wrote:
>> > I have similar concerns as were expressed in the other thread. The
>> > features listed here aren't OVS components and I don't think that it
>> > makes sense for OVS to try to cover everything that is related - the
>> > goal that we've been working towards is to have OVS be less monolithic
>> > and more integrated. So to the extent that it is necessary to have
>> > capabilities be exposed (and I would like to avoid this where
>> > possible), it should be in the individual component, not in OVS.
>
> Fair enough. Note that the IPv6 flag really belongs to ovs, though -
> it's about the existence of OVS_TUNNEL_KEY_ATTR_IPV6_SRC and
> OVS_TUNNEL_KEY_ATTR_IPV6_DST netlink attributes. For the lwtunnel flag
> (which is just another way to tell whether vxlan/geneve/etc. has
> COLLECT_METADATA support) I can agree that it does not belong to ovs.

We actually already have a mechanism for handling compatibility as new
keys are added without requiring capabilities bits - see
Documentation/networking/openvswitch.txt. We've used this quite a few
times, including the addition of baseline tunnel capabilities.

That doesn't really cover IPv6 capability for individual tunneling
protocols though (which could vary on a per-protocol basis).
