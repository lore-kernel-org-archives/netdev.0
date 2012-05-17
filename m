From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [PATCH] e1000: Reset rx ring index on receive
	overrun
Date: Fri, 18 May 2012 01:28:21 +0200
Message-ID: <20120517232821.GJ683@type.famille.thibault.fr>
References: <20120517230140.GZ683@type.famille.thibault.fr>
	<061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jpirko@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Dean Nelson <dnelson@redhat.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Dave, Tushar N, le Thu 17 May 2012 23:22:31 +0000, a =E9crit :
> I am interested in to see if you have actual test case and more important=
ly test data that shows that kernel and device indexes are not synchronized=
 any more.

Well, it's not with an actual physical device, but with the kvm
emulation. Printing indexes from the clean_rx handler, I'm getting:

(status linux index/total size/device index)

status 7 2/256/19
status 7 3/256/19
...
status 7 18/256/19
status 7 19/256/19
status 7 20/256/19
status 7 21/256/19
...
since the status is still 7, linux continues on.

...
status 7 254/256/19
status 7 255/256/19
status 7 0/256/19
status 7 1/256/19
status 0 2/256/19

here it stops, and on next interrupts,

status 0 2/256/20

status 0 2/256/21
etc. and no progress is made any more, until

status 0 2/256/253
status 0 2/256/254

and it gets stuck there:

status 0 2/256/254
status 0 2/256/254
status 0 2/256/254

Samuel

---------------------------------------------------------------------------=
---
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and =

threat landscape has changed and how IT managers can respond. Discussions =

will include endpoint security, mobile security and the latest in malware =

threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
