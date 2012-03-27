From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Tue, 27 Mar 2012 14:43:11 -0400
Message-ID: <CAAsGZS7+L5Y7Mo8pipJf=T6x9vTUAcTS93t=BGsmCUvA3T31Zw@mail.gmail.com>
References: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
	<CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
	<20120326152730.GA10212@localhost.localdomain>
	<CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS4Jqe5ZcZyGZjurmjBCgzj=+a0cgHAEwB+esXNoQ3P7NQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC1A0@ORSMSX105.amr.corp.intel.com>
	<20120327180501.GA3878@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DC68D@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <02874ECE860811409154E81DA85FBB580DC68D@ORSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2012 at 2:29 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:

>>
>
> It isn't so much about performance gains as it is about preventing poorly written user apps from stalling the clean descriptor routines. I am working on a test case that should prove whether this is even an issue (at least with ixgbe). Once I have data on that it can be determined if the extra lock would alleviate it. The conceptual issue is that spamming get-time could cause the clean tx/rx irq routines to stall inside the interrupt for too long. (thereby not freeing up descriptors on the ring to

What would be interesting to see is something like:

1) App1(getter/setter calls), executed '1000' ioctls per sec on eth0.
Other 'M' apps(execute just get calls), where M = 1 .. 10(?). And one
buggy app executed - 10K getter calls per sec.

2) eth0 receives PTP traffic and also around 80-90%(link rate)
regular/mixed traffic.

And BTW, eth0 is the management IP.

While the test is running, if we are still able to reach the host and
manage it via SSH then we can stop being paranoid.


Chetan

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
