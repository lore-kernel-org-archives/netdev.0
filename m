From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 15:27:18 +0200
Message-ID: <4857BBB6.6010709@trash.net>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net> <4857B30B.8020809@trash.net> <20080617130910.GA4632@ff.dom.local> <4857B720.1070302@trash.net> <20080617132410.GB4632@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64221 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756488AbYFQN1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:27:21 -0400
In-Reply-To: <20080617132410.GB4632@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Jun 17, 2008 at 03:07:44PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> On Tue, Jun 17, 2008 at 02:50:19PM +0200, Patrick McHardy wrote:
>>> ...
>>>> Thanks for testing. Unfortunately the module unload races look
>>>> more complicated to fix and I'm busy with other things, so it
>>>> would great if someone else could fix this.
>>> Patrick, I wonder if simply adding an additional mutex e.g.
>>> genl_lock_table() around all the rest (after your patch) genl_locks
>>> could be enough until some major rework. This should prevent any
>>> new races and there are no lockups, I guess?
>> Not sure I understand you correctly, where exactly would
>> this mutex be taken?
> 
> Around (before) each genl_lock(), so any change would need these two
> locks. genl_lock() alone would work like read lock (plus cb change).
> But, I can miss something... Of course, it's meant as a temporary
> solution, until Thomas does it right.

I guess that might work. But simply using module references to
prevent the module from going away while the mutex is not held
doesn't appear to be more complicated.
