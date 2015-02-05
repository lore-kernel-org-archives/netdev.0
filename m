From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH v2] net: openvswitch: Support masked set actions.
Date: Wed, 4 Feb 2015 20:01:46 -0800
Message-ID: <CAEP_g=8+Zs3FXLg5oEQcUaYkNUi44Jnn5_UEjVwos-_ihu=1qw@mail.gmail.com>
References: <1423095381-12243-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:51797 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751979AbbBEECI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:02:08 -0500
Received: by mail-qc0-f176.google.com with SMTP id c9so4804629qcz.7
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 20:02:07 -0800 (PST)
In-Reply-To: <1423095381-12243-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 4:16 PM, Jarno Rajahalme <jrajahalme@nicira.com> wrote:
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
> returning actions to userspace, the set actions that were converted to
> masked set actions are converted back to normal set actions.  We use a
> kernel internal action code to be able to tell the userspace provided
> and converted masked set actions apart.
>
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> ---
> v2: Fixed checkpatch warnigns and errors, rebase.

I had a few minor comments in my review from December 10th, can you take a look?
