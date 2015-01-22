From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH] net: openvswitch: Support masked set actions.
Date: Thu, 22 Jan 2015 14:41:05 -0800
Message-ID: <CALnjE+pCb_WCT=0ZUbK80__WFJEernoBU=35PvdPNDEZuF+sgQ@mail.gmail.com>
References: <1418170225-9328-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:48994 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751597AbbAVWlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 17:41:07 -0500
Received: by mail-ig0-f171.google.com with SMTP id r10so3098061igi.4
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 14:41:05 -0800 (PST)
In-Reply-To: <1418170225-9328-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 4:10 PM, Jarno Rajahalme <jrajahalme@nicira.com> wrote:
> OVS userspace already probes the openvswitch kernel module for
> OVS_ACTION_ATTR_SET_MASKED support.  This patch adds the kernel module
> implementation of masked set actions.
>
> The existing set action sets many fields at once.  When only a subset
> of the IP header fields, for example, should be modified, all the IP
> fields need to be exact matched so that the other field values can be
> copied to the set action.  A masked set action allows modification of
> an arbitrary subset of the supported header bits without requiring the
> rest to be matched.
>
> Masked set action is now supported for all writeable key types, except
> for the tunnel key.  The set tunnel action is an exception as any
> input tunnel info is cleared before action processing starts, so there
> is no tunnel info to mask.
>
> The kernel module converts all (non-tunnel) set actions to masked set
> actions.  This makes action processing more uniform, and results in
> less branching and duplicating the action processing code.  When
> returning actions to userspace, the fully masked set actions are
> converted back to normal set actions.  We use a kernel internal action
> code to be able to tell the userspace provided and converted masked
> set actions apart.
>
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> ---

checkpatch few gave few warnings. otherwise looks good.
