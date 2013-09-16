From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Mon, 16 Sep 2013 16:52:06 +0300
Message-ID: <20130916165206.6d1caf52@jpm-OptiPlex-GX620>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com>
	<CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com>
	<20130915091400.49f90bc4@jpm-OptiPlex-GX620>
	<AE90C24D6B3A694183C094C60CF0A2F6026B733A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Or Gerlitz" <or.gerlitz@gmail.com>,
	"Prarit Bhargava" <prarit@redhat.com>, <netdev@vger.kernel.org>,
	"Doug Ledford" <dledford@redhat.com>,
	"Amir Vadai" <amirv@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:56512 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801Ab3IPNwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 09:52:03 -0400
Received: by mail-ee0-f52.google.com with SMTP id c41so2007627eek.25
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 06:52:02 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B733A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Sep 2013 09:59:41 +0100
"David Laight" <David.Laight@ACULAB.COM> wrote:

> > In any event, this change cannot hurt.  
> 
> It could hide a real 'used but not initialised' error later on...
> 
> 	David

In this case, it doesn't.  If cq_res_start_move_to returns 0, the "cq"
pointer points to the desired cq object.  In all instances where the cq
object is not found, you get an error return, and the cq pointer in the
caller is never de-referenced.

Therefore, the compiler warning is a false positive, and the
"uninitialized_var" is just a workaround to satisfy the compiler.

Same for the SRQ case.

-Jack
