From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 13:24:10 +0000
Message-ID: <20080617132410.GB4632@ff.dom.local>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net> <4857B30B.8020809@trash.net> <20080617130910.GA4632@ff.dom.local> <4857B720.1070302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:58752 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757198AbYFQNT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:19:56 -0400
Received: by ik-out-1112.google.com with SMTP id c28so4554806ika.5
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 06:19:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4857B720.1070302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 03:07:44PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Tue, Jun 17, 2008 at 02:50:19PM +0200, Patrick McHardy wrote:
>> ...
>>> Thanks for testing. Unfortunately the module unload races look
>>> more complicated to fix and I'm busy with other things, so it
>>> would great if someone else could fix this.
>>
>> Patrick, I wonder if simply adding an additional mutex e.g.
>> genl_lock_table() around all the rest (after your patch) genl_locks
>> could be enough until some major rework. This should prevent any
>> new races and there are no lockups, I guess?
>
> Not sure I understand you correctly, where exactly would
> this mutex be taken?

Around (before) each genl_lock(), so any change would need these two
locks. genl_lock() alone would work like read lock (plus cb change).
But, I can miss something... Of course, it's meant as a temporary
solution, until Thomas does it right.

Jarek P.
