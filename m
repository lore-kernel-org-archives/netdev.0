From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks for netdevs
Date: Fri, 19 Feb 2016 10:16:10 +0200
Message-ID: <CAJ3xEMhrAa7+rzdA9Ejs3YTMa3QP0v=VQPOAz0rJ-6pOQoz3WA@mail.gmail.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
	<20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
	<56C4528E.5090505@mojatatu.com>
	<56C48295.9030806@gmail.com>
	<56C4FD2B.9000009@gmail.com>
	<20160218092335.GA15192@office.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Amir Vadai <amir@vadai.me>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37948 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424220AbcBSIQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 03:16:11 -0500
Received: by mail-ig0-f176.google.com with SMTP id y8so30981584igp.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 00:16:11 -0800 (PST)
In-Reply-To: <20160218092335.GA15192@office.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 11:23 AM, Amir Vadai" <amir@vadai.me> wrote:
> On Wed, Feb 17, 2016 at 03:07:23PM -0800, John Fastabend wrote:

>> Actually thinking about this a bit more I wrote this thinking
>> that there existed some hardware that actually cared if it was
>> a new rule or an existing rule. For me it doesn't matter I do
>> the same thing in the new/replace cases I just write into the
>> slot on the hardware table and if it happens to have something
>> in it well its overwritten e.g. "replaced". This works because
>> the cls_u32 layer protects us from doing something unexpected.

>> I'm wondering (mostly asking the mlx folks) is there hardware
>> out there that cares to make this distinction between new and
>> replace? Otherwise I can just drop new and always use replace.
>> Or vice versa which is the case in its current form.

> I don't see a need for such a distinction in mlx hardware.

If you (say) have the same match and different action for a given rule
we have HW API to modify existing steering entry under which we would
end up calling the FW once instead of twice (delete old, add new).

Or.
