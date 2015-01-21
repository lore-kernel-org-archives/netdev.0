From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v13 5/5] openvswitch: Add support for unique flow IDs.
Date: Wed, 21 Jan 2015 10:31:35 -0800
Message-ID: <CALnjE+qHjf5djBybPQUzoR_+dxDskQJQwtgvSN=G5NW9pckETw@mail.gmail.com>
References: <1421778772-11879-1-git-send-email-joestringer@nicira.com>
	<1421778772-11879-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:33583 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753695AbbAUSbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 13:31:36 -0500
Received: by mail-ig0-f182.google.com with SMTP id r10so2421115igi.3
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 10:31:35 -0800 (PST)
In-Reply-To: <1421778772-11879-6-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 10:32 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, flows were manipulated by userspace specifying a full,
> unmasked flow key. This adds significant burden onto flow
> serialization/deserialization, particularly when dumping flows.
>
> This patch adds an alternative way to refer to flows using a
> variable-length "unique flow identifier" (UFID). At flow setup time,
> userspace may specify a UFID for a flow, which is stored with the flow
> and inserted into a separate table for lookup, in addition to the
> standard flow table. Flows created using a UFID must be fetched or
> deleted using the UFID.
>
> All flow dump operations may now be made more terse with OVS_UFID_F_*
> flags. For example, the OVS_UFID_F_OMIT_KEY flag allows responses to
> omit the flow key from a datapath operation if the flow has a
> corresponding UFID. This significantly reduces the time spent assembling
> and transacting netlink messages. With all OVS_UFID_F_OMIT_* flags
> enabled, the datapath only returns the UFID and statistics for each flow
> during flow dump, increasing ovs-vswitchd revalidator performance by 40%
> or more.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Its almost ready. But I saw minor issues,
few checkpatch.pl failures.
in ovs_flow_cmd_new() we should use unmasked key to lookup in flow
table for legacy case.
