From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: partial chunk should be drop without sending
 abort packet
Date: Thu, 27 Aug 2015 21:41:19 +0800
Message-ID: <CADvbK_dFmv1Wp2b_7Gg3dy0tz-Gjt7fvnzGMZP9m88itFMgBtQ@mail.gmail.com>
References: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com>
	<55DB5BFA.3020405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	davem <davem@davemloft.net>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36316 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbbH0NlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 09:41:20 -0400
Received: by obkg7 with SMTP id g7so16109355obk.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 06:41:19 -0700 (PDT)
In-Reply-To: <55DB5BFA.3020405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Actually, silently dropping this is _very_ bad.  There reason is that you've already
> processed the leading chunks and may have potentially queued a response...  Now, you
> reach the end of the packet and find that the last chunk is partial.  You end up
> dropping the packet, but still handing the responses.  This actually lead to some very
> interesting issues we were seeing.
>
> It is better to terminate the association in this case.
>
> -vlad
>

make sense, I just cannot ensure we are doing this as RFC, after all,
it doesnot say
we should send abort in this case clearly.
