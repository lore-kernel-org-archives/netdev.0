From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 23:12:52 +0200
Message-ID: <20090531211252.GC2777@ami.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<1243777427.3966.243.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243777427.3966.243.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 31, 2009 at 09:43:47AM -0400, jamal wrote:
> On Sun, 2009-05-31 at 09:24 -0400, jamal wrote:
> 
> > This would imply the classifier is buggy. I will stare at the different
> > classifier - and if any exhibits such traits it needs to be fixed
> 
> I couldnt find any case where this is possible in the current code. If
> you have a specific example, we need to fix it.

I'm almost sure these commands (right or wrong) can trigger such a leak:

$ sudo tc qdisc add dev lo root handle 1: htb
$ sudo tc filter add dev lo proto ip pref 1 handle 800::1 u32 match u32 0 0 classid 1:1
$ sudo tc filter add dev lo proto ip pref 2 handle 800::1 u32 match u32 0 0 classid 1:1
RTNETLINK answers: File exists

Cheers,
Jarek P.
