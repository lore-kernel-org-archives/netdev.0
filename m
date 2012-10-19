From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH net-next] packet mmap : allow the user to choose tx data
 offset.
Date: Fri, 19 Oct 2012 15:50:18 +0200
Message-ID: <50815A9A.7050009@onera.fr>
References: <1350631302-16280-1-git-send-email-paul.chavent@onera.fr> <CAD6jFURov5oB+ck33JzCYQoBo9mYsEM9c0rHz9gmcgdMKgmwCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:41087 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab2JSNxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 09:53:12 -0400
In-Reply-To: <CAD6jFURov5oB+ck33JzCYQoBo9mYsEM9c0rHz9gmcgdMKgmwCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a point where I'm wrong in my last reply :

On 10/19/2012 01:36 PM, Daniel Borkmann wrote:
>> +               int off;
>
> For offsets, better use off_t, or here u32. Also, add a newline after
> variable declaration.

i use int because of arithmetics :
off_max = po->tx_ring.frame_size - tp_len;

If the user give a bad tp_len (> po->tx_ring.frame_size), with unsigned 
we will probably miss the check that follow :
		
if (unlikely((off < off_min) || (off_max < off)))
