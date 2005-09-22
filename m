From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 15:05:50 +0200
Message-ID: <4332AC2E.8000607@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com>
	<200509191948.55333.ak@suse.de>	<432FDAC5.3040801@cosmosbay.com>
	<200509201830.20689.ak@suse.de>	<433082DE.3060308@cosmosbay.com>
	<43308324.70403@cosmosbay.com>	<4331D168.6090604@cosmosbay.com>
	<20050922124803.GH26520@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050922124803.GH26520@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte a =E9crit :
> On Wed, Sep 21, 2005 at 11:32:24PM +0200, Eric Dumazet wrote:
>=20
>>Patch 2/3 (please apply after Patch 1/3)
>>
>>2) Loop unrolling
>=20
>=20
> First of all, thanks for your performance analysis and patches.  I'm
> very inclined of merging them.
>=20
>=20
>>It seems that with current compilers and CFLAGS, the code from
>>ip_packet_match() is very bad, using lot of mispredicted conditional br=
anches I made some patches=20
>>and generated code on i386 and x86_64
>>is much better.
>=20
>=20
> This only describes your "compare_if_lstrings()" changes, and I'm happy
> to merge them.
>=20
> However, you also removed the use of the FWINV macro and replaced it by
> explicit code (including the bool1/bool2 variables, which are not reall=
y
> named intuitively).  Why was this neccessary?
>=20

It was necessary to get the best code with gcc-3.4.4 on i386 and gcc-4.0.=
1 on=20
x86_64

For example :

bool1 =3D FWINV(ret !=3D 0, IPT_INV_VIA_OUT);
if (bool1) {

gives a better code than :

if (FWINV(ret !=3D 0, IPT_INV_VIA_OUT)) {

(one less conditional branch)

Dont ask me why, it is shocking but true :(

Eric
