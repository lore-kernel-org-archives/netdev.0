From: Edgar Toernig <froese@gmx.de>
Subject: Re: [PATCH] Consolidate multiple implementations of jiffies-msecs
 conversions.
Date: Fri, 26 Mar 2004 21:45:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040326214507.0af7c06b.froese@gmx.de>
References: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
	<20040326014403.39388cb8.froese@gmx.de>
	<Pine.LNX.4.58.0403261007370.6718@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0403261007370.6718@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> 
> On Fri, 26 Mar 2004, Edgar Toernig wrote:
> 
> > Sridhar Samudrala wrote:
> > >
> > >[...]
> > > -#define MSECS(ms)  (((ms)*HZ/1000)+1)
> > > -return (((ms)*HZ+999)/1000);
> > > +return (msecs / 1000) * HZ + (msecs % 1000) * HZ / 1000;
> >
> > Did you check that all users of the new version will work correctly
> > with your rounding?  Explicit round-up of delays is often required,
> > especially when talking to hardware...
>[...] 
> I guess you are referring to cases when HZ < 1000(ex: 100) and msecs is
> less than 10. In those cases, the new version returns 0, whereas some of the
> older versions return 1.

Exactly - but not only <10.  Any value that is not exactly representable
in jiffies.  I.e. for a delay of 15ms one has to wait 2 jiffies on a 100HZ
system.  Your version would give 1 jiffy = 10ms -- too short.

Ciao, ET.
