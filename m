From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 6/6] openvswitch: Support VXLAN Group Policy extension
Date: Wed, 7 Jan 2015 17:18:04 -0800
Message-ID: <CAEP_g=_t_KMUdit7WUSg+OORh=FoQtzLyygaVMftyDV-tAxJvA@mail.gmail.com>
References: <cover.1420594925.git.tgraf@suug.ch> <9c1b0b0acde09019acb61b9b1a4eb4b18c62642a.1420594925.git.tgraf@suug.ch>
 <CAEP_g=__Ssxj3B_0sbp5D+Gh8YmQ7ub9giK4A_QYWVmYctjm-w@mail.gmail.com> <20150107230155.GC21149@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:46540 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755925AbbAHBSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 20:18:25 -0500
Received: by mail-qa0-f47.google.com with SMTP id f12so350112qad.6
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 17:18:24 -0800 (PST)
In-Reply-To: <20150107230155.GC21149@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 3:01 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/07/15 at 02:46pm, Jesse Gross wrote:
>> On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > The group policy metadata is handled in the same way as Geneve options
>> > and transported as binary blob in a new Netlink attribute
>> > OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS which is mutually exclusive to the
>> > existing OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS.
>>
>> Can you explain some more what the encoding would look like if
>> additional options were defined (including ones that are potentially
>> mutually exclusive)? The Geneve options are binary but that is coming
>> directly from the protocol specification. However, this isn't an on
>> the wire format so I'm not sure what it would look like or how it
>> would be defined to avoid conflict and allow evolution.
>
> The encoding will be based on struct ovs_vxlan_opts which is extended
> as needed by appending new members to the end of the struct. Parsers
> will look at the provided length to see which fields are provided.

But this means that if there are two extensions that are conflicting
or if one is retired you still need to carry the earlier members of
the struct. Why not make them real netlink attributes?
