From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next v1 3/4] net-e1000e: reworked
	carrier detection logic
Date: Tue, 22 Nov 2011 12:32:45 -0800
Message-ID: <CAHo-OozdBn5jBNsRVzbCnmxozquJnTAYa0bNbK5VoaiKaK=7qQ@mail.gmail.com>
References: <cover.1321917278.git.david.decotigny@google.com>
	<3badc590e12be93a2d2ffbf998d138a81e6e7181.1321917278.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: David Decotigny <david.decotigny@google.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <3badc590e12be93a2d2ffbf998d138a81e6e7181.1321917278.git.david.decotigny@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David,

I know you asked for a review of this on Friday, before you sent this
out to netdev, and I was planning on doing so, but I see you've sent
it out to a wider audience now.
So, I'll attach comments directly here.

You took my patch (which was for 2.6.34) and split it in two (it was
erroneously marked author zenczykowski@gmail.com instead of
maze@google.com, so that should be fixed) and while you seem to have
reduced the amount of lines-of-code-churn, I'm not sure you've
actually made the resulting code (as a whole) more readable.

I'm not sure how much of these changes were a result of changes
elsewhere in the driver between 2.6.34 and now.

This was very tricky code to get right, and I'm not sure whether the
patch as you posted it gets all the corner cases right...
Indeed I actually think the changes you've made reduce the robustness
wrt. timeouts caused by firmware concurrent accesses.  In particular
the first read access you make is very likely to fail.
I think renaming success to link and iterations to intervals was
worthwhile since it improved readability...

For reference, the original patch, cherrypicked onto net-next and
compile (but not anything else) tested will be a reply to this email.

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
