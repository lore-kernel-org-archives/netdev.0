From: bert hubert <ahu@ds9a.nl>
Subject: Re: Strangeness when write()-ing zero-length datagrams
Date: Mon, 9 Aug 2004 17:40:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809154057.GA30659@outpost.ds9a.nl>
References: <19357.1092062293@www39.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael T Kerrisk <mtk-lists@gmx.net>
Content-Disposition: inline
In-Reply-To: <19357.1092062293@www39.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 09, 2004 at 04:38:13PM +0200, Michael T Kerrisk wrote:
> Godday,
> 
> On Linux 2.4.26 and 2.6.7, if we connect a datagram socket and 
> then use write() to send 0 bytes, a datagram is NOT generated 
> (this happens in both the Unix and Internet domains).  
> Datagrams are generated in this case for send() and sendto() 
> though.

Some postings were made about this some time ago, it appears SUS has an
opinion on zero byte writes:

If nbyte is 0, write() will return 0 and have no other results if the file
is a regular file; otherwise, the results are unspecified.
http://www.opengroup.org/onlinepubs/007908799/xsh/write.html

The send(2) manpage states:

The send() function is identical to sendto() with a null pointer dest_len
argument, and to write() if no flags are used.

Which means that a zero byte send() without flags is unspecified.

Also note that it is hard if impossible to usefully inform userspace of the
reception of a zery byte packet - returning 0 from recvfrom may also mean an
'orderly shutdown'.

Do you actually have a need for zero byte packets?

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
