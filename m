From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/5] switchdev: use new swdev ops
Date: Sun, 15 Mar 2015 17:43:13 -0700
Message-ID: <CAE4R7bCm5H2mozRnRWwStrnXEyZY53nmjQq3i3rh4UvRetLFdQ@mail.gmail.com>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
	<1426400107-6072-3-git-send-email-sfeldma@gmail.com>
	<20150315234453.GB16756@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:33824 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbbCPAnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 20:43:14 -0400
Received: by qcaz10 with SMTP id z10so31485350qca.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 17:43:13 -0700 (PDT)
In-Reply-To: <20150315234453.GB16756@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 4:44 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi Scott,
>
> On Sat, Mar 14, 2015 at 11:15:04PM -0700, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Move swdev wrappers over to new swdev ops (from previous ndo ops).  No
>> functional changes to the implementation.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> I am a little concerned that this patch will break rocker and dsa until
> the 3rd and 4th patches of this series are applied.

Ya, I think you're right.  I was trying to be careful to not break git
bisect, but looks like I only covered the compile case, and broke the
run-time case.  I don't see anyway around this other than squashing
the rocker/dsa patches in with this one.  I'll send v2.

>
> Also it is not entirely obvious to me why you check for !ops in
> netdev_switch_parent_id_get() and netdev_switch_port_stp_update()
> but not in netdev_switch_fib_ipv4_add() and netdev_switch_fib_ipv4_del().

In the fib cases, we find the port dev from the route nexthop dev by
checking if we had swdev_parent_id_get, so we already know ops is
valid.

-scott
