From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: TCP hangs
Date: Tue, 04 May 2004 09:48:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4097C966.5080509@us.ibm.com>
References: <Pine.LNX.4.58.0405021602120.20423@artax.karlin.mff.cuni.cz> <409583B1.5040906@us.ibm.com> <Pine.LNX.4.58.0405031238110.18691@artax.karlin.mff.cuni.cz> <4097B8D1.4010008@us.ibm.com> <Pine.LNX.4.58.0405041811300.11971@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
In-Reply-To: <Pine.LNX.4.58.0405041811300.11971@artax.karlin.mff.cuni.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mikulas Patocka wrote:

>TCP should send RST on received data after shutdown(SHUT_RD) ---
>RFC2525, sections 2.16, 2.17.
>  
>

Yes, but that should lead to a shutdown on both ends. If you
have sent a reset, why are you not tearing down your end of
whatever remains of the connection? You have asked the
other side to tear down. RFC 793:

"The receiver of a RST first validates it, then changes 
state.  If the receiver was in the LISTEN state, it ignores it.  
If the receiver was in SYN-RECEIVED state and had previously 
been in the LISTEN state, then the receiver returns to the 
LISTEN state, otherwise the receiver aborts the connection 
and goes to the CLOSED state.  If the receiver was in any 
other state, it aborts the connection and advises the user
and goes to the CLOSED state."


>It happens that the stack at the client ignores seq number if packet
>doesn't contain any data. I fixed the client so that it replies with ack,
>if sequence number doesn't match. Is it correct fix?
>

That will work. 

>The app didn't go away, it just called close.
>

See above.

>App was just not receiving any data, until I stopped the connection in
>browser.
>
>Mikulas
>  
>

Hmm, that sounds like a root cause issue, then (why the app wasn't
receiving data in the first place)..

Thanks for the info..

Nivedita
