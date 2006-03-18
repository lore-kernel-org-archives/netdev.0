From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Sat, 18 Mar 2006 15:10:00 +1000
Message-ID: <1142658600.4218.39.camel@ras.pc.stuart.local>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142225063.14909.77.camel@ras.pc.brisbane.lube>
	<1142269090.5242.29.camel@jzny2> <4415B217.30507@trash.net>
	<20060313100421.7df7f9ed@localhost.localdomain>
	<1142286237.17608.7.camel@ras.pc.brisbane.lube>
	<20060313135048.27b09fba@localhost.localdomain>
	<1142296295.17608.112.camel@ras.pc.brisbane.lube>
	<1142303082.5219.16.camel@jzny2>
	<1142306212.17608.178.camel@ras.pc.brisbane.lube>
	<1142307572.5219.73.camel@jzny2>
	<1142312708.17608.270.camel@ras.pc.brisbane.lube>
	<1142436098.5346.3.camel@jzny2>
	<1142470323.17608.341.camel@ras.pc.brisbane.lube>
	<1142472481.5417.20.camel@jzny2>
	<1142476647.17608.394.camel@ras.pc.brisbane.lube>
	<1142478478.5417.46.camel@jzny2>
	<1142488027.17608.485.camel@ras.pc.brisbane.lube>
	<1142517116.5417.137.camel@jzny2>
	<1142551481.17608.589.camel@ras.pc.brisbane.lube>
	<1142606049.5322.89.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1142606049.5322.89.camel@jzny2>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Fri, 2006-03-17 at 09:34 -0500, jamal wrote:
> - the 2.4 algorithm performs very poorly for < 8 bits if you use a
> standard mask for ALL cases except when you use a lot of memory, most of
> which is _wasted_, in which case it performs equally. There are only 8
> masks in an 8 bit ranging from length of 1 to 8. Should not be hard to prove
> or disprove. Should be very easy to see when you plot.

Agreed.

> - You made the claim the 2.6 algorithm performs poorly if you had
> a 16 bit mask. You showed one sample of data. I dont even remember your
> sample anymore because you keep bombarding me with a lot of claims.
> I gave you the parameters which will help convince me. I showed you a 
> sample using similar parameters why the old one was buggy in the case of 
> 8 bits. There are only 16 possible masks for 16 bits (of length 1-16).
> Why cant you just give me similar results? Why do we have to go back
> and forth with a lot of hand waving when we can settle this easily?

I guess there are a couple of points here I don't understand:

- I don't see how 2.4 was "buggy", but perhaps we have different
  definitions of buggy.  I regard giving the wrong result as
  buggy.  Neither algorithm does that.

- I don't understand your point about "there are only 16 
  possible masks for 16 bits".  What do you want me to show?

> I will not respond to any further emails which do not contain 
> data - instead I am going to produce mine.

Put the 2.4 vs 2.6 argument aside.  The best solution as is 
to adopt the "new" algorithm I proposed.  Here is why:

1.  It can emulate either the 2.4 or 2.6 algorithm by a
    suitable choice of mask.  I can prove formally this 
    if you need me to.

2.  There is no dataset where the "new" algorithm is slower 
    than either 2.4, or 2.6.  This follows from (1).

3.  There are datasets where it is faster than the 2.6,
    algorithm, and datasets where it is faster than the
    2.4 algorithm.

    This follows from the fact that there are datasets
    where 2.6 is faster than 2.4, and there are datasets
    where 2.4 is faster than 2.6.  I think you know this
    already, but if not I can give some simple examples
    to prove it - just ask.

4.  Timing.  If we are going to change the algorithm,
    this is the time to do it - while the algorithm in
    "tc" is wrong and must be changed anyway.

For your convenience I have cut & pasted from the previous
email the comparison of the 2.4, 2.6 and "new" algorithm:

  2.4 Algorithm:           2.6 algorithm:       New Algorithm:
  --------------           --------------       --------------
  hash = (hash>>16)^hash;  hash = hash>>shift;  hash = hash>>shift;
  hash = (hash>>8)^hash;   return hash & 0xff;  hash = (hash>>16)^hash;
  return hash & 0xff;                           hash = (hash>>8)^hash;
                                                return hash & 0xff;
