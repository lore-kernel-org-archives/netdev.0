From: Ray Cole <ray_cole@earthlink.net>
Subject: Re: r8169 driver in 2.6.6
Date: Wed, 26 May 2004 23:06:32 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526230632.26c4e2e5.ray_cole@earthlink.net>
References: <20040524210148.2172d684.ray_cole@earthlink.net>
	<20040525091915.A12162@electric-eye.fr.zoreil.com>
	<20040525230831.4747005f.ray_cole@earthlink.net>
	<20040525231140.1325daa7.ray_cole@earthlink.net>
	<20040526055841.GH3330@ruslug.rutgers.edu>
	<20040526133645.B32639@electric-eye.fr.zoreil.com>
	<20040526070014.17ee9486.ray_cole@earthlink.net>
	<20040526161508.A3368@electric-eye.fr.zoreil.com>
	<20040526191528.54f4af59.ray_cole@earthlink.net>
	<20040526205324.0913df99.ray_cole@earthlink.net>
	<20040526221742.393e626d.ray_cole@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
In-Reply-To: <20040526221742.393e626d.ray_cole@earthlink.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like it is most definately a gcc 2.95.3 issue.  I turned off optimization (appended -O0 to the compiler command line) and the 'bad' way gives the proper result.  -O1, on the other hand, gives an incorrect result.

BTW, sorry for including the whole chain.  I hadn't been CC'ing netdev as requested until I had a little more definitive answer to keep from flooding everyone's email :-)

So the fix I posted yesterday does get around what appears to be a compiler error in gcc 2.95.3.

-- Ray


On Wed, 26 May 2004 22:17:42 -0500
Ray Cole <ray_cole@earthlink.net> wrote:

> Sure enough, it gives a different result in r8169 with the two methods. 
> Attached is the source that I'm dealing with.  Look for "HERE IS THE
> BUG" :-)
> 
> You'll see for this test I'm using the 'bad' way first, printing its
> result out, then doing it the good way and displaying its result (this
> way I'm able to keep the network running...obviously commenting out the
> 'bad' way still makes it work).
> 
> Here is a snippet from /var/log/mesages.  Note that once it hit entry 63
> things went bad...
> 
> May 26 22:12:04 localhost kernel: Entry 61  len 98
> May 26 22:12:04 localhost kernel: StatusBad : 61 b0000062
> May 26 22:12:04 localhost kernel: StatusGood: 61 b0000062
> May 26 22:12:04 localhost kernel: Entry 62  len 98
> May 26 22:12:04 localhost kernel: StatusBad : 62 b0000062
> May 26 22:12:04 localhost kernel: StatusGood: 62 b0000062
> May 26 22:12:04 localhost kernel: Entry 63  len 98
> May 26 22:12:04 localhost kernel: StatusBad : 63 b0000062
> May 26 22:12:04 localhost kernel: StatusGood: 63 f0000062
> 
> Attached is the 'full' /var/log/messages from the point where I started
> the interface to the point where the failure occured.
> 
> 
> 
> -- Ray
> 
> 
> On Wed, 26 May 2004 20:53:24 -0500
> Ray Cole <ray_cole@earthlink.net> wrote:
> 
> > I had a typo in test.c...I had 'status -' rather than 'status ='. 
> > I've been trying to make it give a different value outside of r8169
> > without any luck.  So I'll rebuild r8169.c and dump the value of the
> > status member in both situations to see if a difference shows...
> > 
> > The only difference between my test case now and r8169.c is the lack
> > of cpu_to_le32... 
> > 
> > Will let you know the results...
> > 
> > -- Ray
> > 
> > 
> > On Wed, 26 May 2004 19:15:28 -0500
> > Ray Cole <ray_cole@earthlink.net> wrote:
> > 
> > > If entry == NUM_TX_DESC - 1 then it makes a difference. 
> > > 
> > > Attached is a short little test program that will show the value of
> > > 'status' is different with the two different statements when entry =
> > > 63.  So basically the last buffer in the ring that gets sent causes
> > > status to be incorrect.
> > > 
> > > Here is sample output from 'test.cpp'.  'Status New' is using the
> > > if/else routine that I pulled from 2.6.5 into 2.6.6's r8169 (the way
> > > that works).  'Status Old' uses the way r8169.c sets status in
> > > 2.6.6.
> > > 
> > >    Status New: 4000b440   Status Old: f00003e8
> > > 
> > > 
> > > -- Ray
> > > 
> > > 
> > > On Wed, 26 May 2004 16:15:08 +0200
> > > Francois Romieu <romieu@fr.zoreil.com> wrote:
> > > 
> > > > Ray Cole <ray_cole@earthlink.net> :
> > > > [...]
> > > > > Let me know if you want me to provide a diff.  I'm not real used
> > > > > to generating diff's, and am not sure which version you want me
> > > > > to diff against (I would assume against 2.6.6).  I'm more than
> > > > > willing to provide it.
> > > > 
> > > > (May be I lack of coffee, but...)
> > > > 
> > > > Can you give me an exemple of value of 'entry' where the change
> > > > could make a difference (you can forget the cpu_to_le32 thing as
> > > > we all live in x86 land) ?
> > > > 
> > > > I have not been able to see one, that's why I would like to
> > > > analyze the modules and see if your compiler has generated correct
> > > > opcode or not.
> > > > 
> > > > But maybe I am just sleeping :o/
> > > > 
> > > > --
> > > > Ueimor
> > > 
> 
