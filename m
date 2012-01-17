From: <abirvalg@lavabit.com>
Subject: Re: /proc/net/tcp6 inconsistent line length
Date: Tue, 17 Jan 2012 16:14:47 +0000
Message-ID: <20120117161447.5ef681c9@wwwwww-701SD>
References: <20120117152919.7746a3f9@wwwwww-701SD>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AF49@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from karen.lavabit.com ([72.249.41.33]:51264 "EHLO karen.lavabit.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab2AQOOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 09:14:38 -0500
Received: from b.earth.lavabit.com (b.earth.lavabit.com [192.168.111.11])
	by karen.lavabit.com (Postfix) with ESMTP id 4A67811BC4C
	for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 08:14:38 -0600 (CST)
Received: from wwwwww-701sd (46.109.128.192)
	by lavabit.com with ESMTP id ESIWKH40IPFP
	for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 08:14:38 -0600
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF49@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jan 2012 13:33:01 -0000
"David Laight" <David.Laight@ACULAB.COM> wrote:

>  
> > My application parses /proc/net/tcp6 at least 4 times per 
> > second, so the overhead of figuring out the length of each 
> > line and subtracting the offset is quite expensive.
> 
> I'd be surprised if you can detect the cost of calling
> strchr(buf, '\n') on each line at the frequency.
> 
> It is probably far less than the other processing you
> do on the line.
> 
> 	David
> 
> 

Thank you, David. I first fread() the whole file to membuf and then process it thusly trying to find a line that matches my source port (porthex) :

while(1){
    memcpy(buffer,&tcp6_membuf[184+170*i],4);
    if ( !memcmp ( porthex, buffer, 4 ) ){ //match!
        goto endloop;
    }
     i++;
     continue;

N.B. 184 is the offset of source port on line 2 from the beginning of file (line 1 is used for column headings)

my /proc/net/tcp6 file contains 300 - 500 lines and I parse it at least from 4 to 10 times per sec. So the maximum is 5000 iterations per sec. It would be very costly CPU wise to do strchr(buf, '\n')
 
I'm not skillful enough to understand the code in kernel sources.
My concern boils down to this:

Was /proc/net/tcp* meant to have an equal length of each line?
If yes, then I discovered a bug.
If no, then would it be possible to patch the kernel to enable an equal length on each line? 
