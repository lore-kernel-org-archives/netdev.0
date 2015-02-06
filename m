From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v3] net: openvswitch: Support masked set actions.
Date: Fri, 6 Feb 2015 11:10:11 -0800
Message-ID: <CALnjE+rnMvV_ApjFtjHm7hWd3_u0tzat-3WMAoOz6SZAx+bBxQ@mail.gmail.com>
References: <1423172449-3654-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:32971 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751899AbbBFTKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 14:10:12 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so4782995igq.0
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 11:10:12 -0800 (PST)
In-Reply-To: <1423172449-3654-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 1:40 PM, Jarno Rajahalme <jrajahalme@nicira.com> wrote:
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
> v3: Clean up code and remove flow key transport port checks from
>     validate_set(), as suggested by Jesse Gross.
>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
