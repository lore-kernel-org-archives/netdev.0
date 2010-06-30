From: Ivan Novick <novickivan@gmail.com>
Subject: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 11:04:18 -0700
Message-ID: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e64ec1acc66160048a432ea5
Cc: jmatthews@greenplum.com, Tim Heath <theath@greenplum.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34993 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab0F3SEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 14:04:20 -0400
Received: by vws5 with SMTP id 5so1274088vws.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 11:04:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e64ec1acc66160048a432ea5
Content-Type: text/plain; charset=ISO-8859-1

Hello all,

Attached is a packet capture from my application that is running on
RedHat Enterprise Linux 5.4

I am seeing a Retransmission timeout but I was hoping this case would
go into fast retransmit and not RTO.

I am wondering why did the sender not send more data?  If the sender
was to send more data and extend the window then it would seem the
duplicate acks or SACKS should trigger fast retransmit.

The application does not constantly send data, but data should arrive
to be sent before 200 milliseconds that it takes for the RTO.

Is it possible that there was no data to send and the window is not
advanced and the sender is waiting for an ACK.  Then data arrives half
way into the RTO 200 milliseconds while waiting for an outstanding ACK
but the window is not advanced?

You can see right after the RTO and retransmission additional data is
sent, so there is additional data.  In theory that additional data
could be arriving right at the 200 milliseconds point, but we see this
pattern in the dump regularly and I believe data is there before the
end of the 200 milliseconds RTO.

As a related point the advertised window from the receiver seems to be
a constant value of 22060, so either the receiver is handling its data
fast enough to never have to reduce its window... or this number is
really not used to indicate space available currently in the receive
window?

Any feedback to help understand why we are not doing fast retransmit
and or why the sender is not extending the window would be greatly
appreciated.

Cheers,
Ivan Novick

--0016e64ec1acc66160048a432ea5
Content-Type: application/octet-stream; name="sender_backoff.cap"
Content-Disposition: attachment; filename="sender_backoff.cap"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gb2h73jw0

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
--0016e64ec1acc66160048a432ea5--
