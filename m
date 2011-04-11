From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 33102] New: File's copied from client->linux
 server only copy 1st 64K data; rest is lost
Date: Mon, 11 Apr 2011 15:24:31 -0700
Message-ID: <20110411152431.a5997005.akpm@linux-foundation.org>
References: <bug-33102-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lkml@tlinx.org
To: netdev@vger.kernel.org, linux-cifs@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43135 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755356Ab1DKWZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:25:25 -0400
In-Reply-To: <bug-33102-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 11 Apr 2011 22:12:41 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=33102
> 
>            Summary: File's copied from client->linux server only copy 1st
>                     64K data;rest is lost
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: lkml@tlinx.org
>         Regression: Yes

Seems to be a 2.6.37->2.6.38 regression.

> 
> Created an attachment (id=54112)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=54112)
> config file
> 
> I've run into a problem copying a 3.6M file from a Win7 client to
> the linux server via cifs.
> 
> 
> Under 2.6.38.2, it only copies the first 64K (exactly) and the
> client gets a write error.
> 
> Using wireshark, in the success case, after the client sends the first
> 64K, the server response with 4 acks  each advertising a Window
> size of ~48K, followed by an SMB packet acknowledging the first 64K, w/info:
>   "WRITE AndX Request, 65536 bytes".
> 
> In the fail case, the server responds with 4 acks, but in each of the
> 4 ACKS, it's advertising strange window sizes of 881, 1161, 1441 1721
> and then responds with a faulty SMB packet w/info:
>   "[TCP Retransmission] Trans2 Response<unknown>"
>  Under the Trans2 section it says:
> 
>   Subcommand: <Unknown> since request packet wasn't seen.
> 
> 
> ----
> 
> I originally upgraded from 2.6.35.7 -> 2.6.38.2 and encountered this
> prob, so successively tried the 26.35.7 config w/2.6.36, 37, 38 and finally
> 38.1 -- they all work.
> 
> The same config on 2.6.38.2 fails as described above.
> 
> 
> Config attached.
> 

