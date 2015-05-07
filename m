From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 3/7] packet: rollover prepare: single return in packet_rcv_has_room
Date: Thu, 7 May 2015 12:05:50 -0400
Message-ID: <CA+FuTSfQJ_PTojBgKCD5mFVNRWmtBXMbgbY=D_WBPswwhsDaLA@mail.gmail.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
 <1430936837-22655-4-git-send-email-willemb@google.com> <063D6719AE5E284EB5DD2968C1650D6D1CB2F5E7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36454 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbEGQGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 12:06:21 -0400
Received: by obbkp3 with SMTP id kp3so34983982obb.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 09:06:21 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB2F5E7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> IMHO there is little benefit in the 'single return from function' style.
> In general it just makes scan-reading of code more difficult (once you
> see a 'return' you know then is no more relevant code) and hits the RH margin.

Subsequent patches add code to the footer of the function. I should
have been more clear about that in the commit message. The change
is indeed not very useful on its own. But at the end of the patch set,
this is the footer:

      has_room = ret == ROOM_NORMAL;
      if (po->pressure == has_room)
              xchg(&po->pressure, !has_room);

      return ret;

which otherwise has to be duplicated.
