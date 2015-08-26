From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv6 net-next 05/10] openvswitch: Add conntrack action
Date: Wed, 26 Aug 2015 11:55:56 -0700
Message-ID: <CANr6G5w_e5QhxPLAR6UEvgDGUa7UCZUuBfABxPoS=zjrayUsjg@mail.gmail.com>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com> <1440613913-10141-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	netfilter-devel@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:34349 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbbHZS4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:56:16 -0400
Received: by ykdt205 with SMTP id t205so197605899ykd.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:56:15 -0700 (PDT)
In-Reply-To: <1440613913-10141-6-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 August 2015 at 11:31, Joe Stringer <joestringer@nicira.com> wrote:
> Expose the kernel connection tracker via OVS. Userspace components can
> make use of the CT action to populate the connection state (ct_state)
> field for a flow. This state can be subsequently matched.
>
> Exposed connection states are OVS_CS_F_*:
> - NEW (0x01) - Beginning of a new connection.
> - ESTABLISHED (0x02) - Part of an existing connection.
> - RELATED (0x04) - Related to an established connection.
> - INVALID (0x20) - Could not track the connection for this packet.
> - REPLY_DIR (0x40) - This packet is in the reply direction for the flow.
> - TRACKED (0x80) - This packet has been sent through conntrack.
>
> When the CT action is executed by itself, it will send the packet
> through the connection tracker and populate the ct_state field with one
> or more of the connection state flags above. The CT action will always
> set the TRACKED bit.
>
> When the COMMIT flag is passed to the conntrack action, this specifies
> that information about the connection should be stored. This allows
> subsequent packets for the same (or related) connections to be
> correlated with this connection. Sending subsequent packets for the
> connection through conntrack allows the connection tracker to consider
> the packets as ESTABLISHED, RELATED, and/or REPLY_DIR.
>
> The CT action may optionally take a zone to track the flow within. This
> allows connections with the same 5-tuple to be kept logically separate
> from connections in other zones. If the zone is specified, then the
> "ct_zone" match field will be subsequently populated with the zone id.
>
> IP fragments are handled by transparently assembling them as part of the
> CT action. The maximum received unit (MRU) size is tracked so that
> refragmentation can occur during output.
>
> IP frag handling contributed by Andy Zhou.

Based on original design by Justin Pettit.

> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
