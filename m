From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: Code query: tcp_request_sock deallocation
Date: Thu, 7 Aug 2008 18:19:32 -0700
Message-ID: <396556a20808071819r39e22ffdg23b6fb10cfa501da@mail.gmail.com>
References: <396556a20808071607o7157932bt373d4b9a5e1bbedb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:23853 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbYHHBTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 21:19:33 -0400
Received: by rv-out-0506.google.com with SMTP id k40so773259rvb.1
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 18:19:33 -0700 (PDT)
In-Reply-To: <396556a20808071607o7157932bt373d4b9a5e1bbedb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 7, 2008 at 4:07 PM, Adam Langley <agl@imperialviolet.org> wrote:
> Other code paths in that function (like goto embryonic_reset) end up
> removing it from the queue and freeing it immediately (with
> inet_csk_reqsk_queue_drop).

It's ok, I found it. What got me was that I put a BUG() in the
destructor and it didn't get called. Turns out that accepting a socket
doesn't call the destructor. Then I spent another hour verifying that
no memory leaks because of that.

I feel it probably should call the destructor, however.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
