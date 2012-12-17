From: RongQing Li <roy.qing.li@gmail.com>
Subject: XFRM: Could we change ESP padding?
Date: Mon, 17 Dec 2012 11:28:05 +0800
Message-ID: <CAJFZqHzDDtUacnQzd-gcS8JBvPdgspozWkUFOogS4nDmvZz7rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34507 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab2LQD2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 22:28:07 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so6567461vcd.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 19:28:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

setkey has the below parameter, but this parameter seems not be
implemented in kernel and userspace,
	
     -f pad_option  defines the content of the ESP padding.
pad_option is one of following:
        zero-pad    All the paddings are zero.
        random-pad  A series of randomized values are used.
        seq-pad     A series of sequential increasing numbers
 started from 1 are used.


and kernel seems not inspect the ESP padding content too, the result
is the packets are not dropped even if they are with a wrong pad
content(not a monotonically increasing sequence).


Could anyone tell me why, bad description in RFC, performance, lack time,
or other reason? Thanks very much!


RFC4303:
If Padding bytes are needed but the encryption algorithm does not
specify the padding contents, then the following default processing
MUST be used.  The Padding bytes are initialized with a series of
(unsigned, 1-byte) integer values.  The first padding byte appended
to the plaintext is numbered 1, with subsequent padding bytes making
up a monotonically increasing sequence: 1, 2, 3, ....  When this
padding scheme is employed, the receiver SHOULD inspect the Padding
field.  (This scheme was selected because of its relative simplicity,
ease of implementation in hardware, and because it offers limited
protection against certain forms of "cut and paste" attacks in the
absence of other integrity measures, if the receiver checks the
padding values upon decryption.)


Thanks

-RongQing
