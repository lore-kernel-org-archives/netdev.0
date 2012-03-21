From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Wed, 21 Mar 2012 17:50:34 -0400
Message-ID: <CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
	<CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321170003.GA5533@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
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
In-Reply-To: <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2012 at 1:09 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:
>> -----Original Message-----
>> From: Richard Cochran [mailto:richardcochran@gmail.com]
>> Sent: Wednesday, March 21, 2012 10:00 AM
>> To: chetan loke
>> Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Keller, Jacob
>> E; Kirsher, Jeffrey T; Ronciak, John; john.stultz@linaro.org;
>> tglx@linutronix.de
>> Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
>> timecompare method
>>
>> Can you please explain how using a seqlock could help here?
>>
>> Thanks,
>> Richard
>
> My understanding of the seqlock, is that it prevents starvation of the hwtstamp calls in the rx and tx routines if/when a user hammers the gettime ioctl due to bad software design where 100+ apps are wanting direct access to the PHC.
>

Richard - Intent is to make the readers(get_time) wait (or return last
read value if the seq_counter tripped because you know that this value
was recent) and let the tx/rx path continue. I haven't looked in more
details but as Jake mentioned you will also need to change the way you
read the values(by not using timecounter_read in get_time).

thanks
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
