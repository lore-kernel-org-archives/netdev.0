From: Yann Ylavic <ylavic.dev@gmail.com>
Subject: Dynamic number of TCP listeners and SO_REUSEPORT
Date: Tue, 25 Mar 2014 14:41:34 +0100
Message-ID: <CAKQ1sVMzoVG9rBAR7fUOTp4eXxUWXLMhcYt-SHyKec=9_vLB-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f196.google.com ([209.85.223.196]:46749 "EHLO
	mail-ie0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbaCYNle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:41:34 -0400
Received: by mail-ie0-f196.google.com with SMTP id rd18so153554iec.3
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:41:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while trying to modify some server's code to take advantage of the new
SO_REUSEPORT option (introduced in 3.9), I'm currently facing the
problem described in the original commit message
(https://lwn.net/Articles/542738/) :

"The TCP implementation has a problem in that the request sockets for a
listener are attached to a listener socket.  If a SYN is received, a
listener socket is chosen and request structure is created (SYN-RECV
state).  If the subsequent ack in 3WHS does not match the same port
by so_reusport, the connection state is not found (reset) and the
request structure is orphaned.  This scenario would occur when the
number of listener sockets bound to a port changes (new ones are
added, or old ones closed).  We are looking for a solution to this,
maybe allow multiple sockets to share the same request table..."

If the number of listening processes is (forcibly) made constant,
things work well and performances are really improved compared to not
using the option (accept mutex, odd scheduling...).
However this is not the model used by the server, and recycling
processes is also part of its scalability.

My tests are with the latest 3.13, but I could not find any reference
for this issue on the list since the original commit...

Is this something still being worked on, planned, or already fixed in
the latest kernel versions?

Thanks for your answers/pointers.

Regards,
Yann.
