From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: [RFC 2/2] igb: skb recycling
Date: Fri, 24 Oct 2008 12:01:19 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F209BBD1C@orsmsx501.amr.corp.intel.com>
References: <20081021121137.5c67d338@extreme>
	<80769D7B14936844A23C0C43D9FBCF0F176AE5E0@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_80769D7B14936844A23C0C43D9FBCF0F209BBD1Corsmsx501amrcor_"
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Stephen Hemminger
	<shemminger@vyatta.com>, "jeffery.t.kirsher@intel.com"
	<jeffery.t.kirsher@intel.com>, "Brandeburg, Jesse"
	<jesse.
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F176AE5E0@orsmsx501.amr.corp.intel.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--_002_80769D7B14936844A23C0C43D9FBCF0F209BBD1Corsmsx501amrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Duyck, Alexander H wrote:
> Stephen Hemminger wrote:
>> This driver is multiqueue, so implement a small skb recycling queue
>> per cpu. It doesn't make sense to have a global queue since then a
>> lock would be required. Not sure if this is going to work; compile
>> tested only, needs more evaluation
>=20
> I did a bit of quick testing and found an issue in the sections of
> code below.  As is the current patch generates a null pointer
> exception on unload because the percpu_alloc and
> for_each_possible_cpu are working off of two different CPU masks.  =20
>=20
> The simple solution is to either replace percpu_alloc with
> alloc_percpu and use cpu_possible_map or replace
> for_each_possible_cpu with for_each_online_cpu and use the
> cpu_online_map.  =20
>=20
> Attached is the version I tested at my desk that used the
> cpu_possible_map solution.  I went that route since alloc_percpu
> seemed like a fairly clean macro. =20

It turns out I missed one issue in my testing that was brought to my attent=
ion.  It looks like the issue was just due to the fact that the per cpu que=
ues weren't initialized to store packets.  This updated patch adds a loop t=
hat goes through and calls __skb_queue_init_head on all the queues.

Thanks,

Alex=

--_002_80769D7B14936844A23C0C43D9FBCF0F209BBD1Corsmsx501amrcor_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
--_002_80769D7B14936844A23C0C43D9FBCF0F209BBD1Corsmsx501amrcor_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--_002_80769D7B14936844A23C0C43D9FBCF0F209BBD1Corsmsx501amrcor_--
