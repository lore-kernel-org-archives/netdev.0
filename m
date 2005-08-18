From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is
 now allocated only on demand.
Date: Thu, 18 Aug 2005 08:51:03 +0200
Message-ID: <43042FD7.40204@cosmosbay.com>
References: <20050810164655.GB4162@linux.intel.com>	 <20050810.135306.79296985.davem@davemloft.net>	 <20050810211737.GA21581@linux.intel.com>	 <430391F1.9080900@cosmosbay.com>	 <20050817211829.GK27628@wotan.suse.de>	 <4303AEC4.3060901@cosmosbay.com> <20050817215357.GU3996@wotan.suse.de>	 <4303D90E.2030103@cosmosbay.com> <2cd57c90050817183942b217fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <ak@suse.de>, Benjamin LaHaise <bcrl@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750862AbVHRGvZ@vger.kernel.org>
To: Coywolf Qi Hunt <coywolf@gmail.com>
In-Reply-To: <2cd57c90050817183942b217fa@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Coywolf Qi Hunt a =E9crit :
> On 8/18/05, Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>>Andi Kleen a =E9crit :
>>
>>
>>>>(because of the insane struct file_ra_state f_ra. I wish this struc=
ture
>>>>were dynamically allocated only for files that really use it)
>>>
>>>
>>>How about you submit a patch for that instead?
>>>
>>>-Andi
>>
>>OK, could you please comment this patch ?
>>
>>The problem of dynamically allocating the readahead state data is tha=
t the allocation can fail and should not be fatal.
>>I made some choices that might be not good.
>>
>>I also chose not to align "file_ra" slab on SLAB_HWCACHE_ALIGN becaus=
e the object size is 10*sizeof(long), so alignment would loose
>>6*sizeof(long) bytes for each object.
>>
>>
>>[PATCH]
>>
>>* struct file cleanup : the very large file_ra_state is now allocated=
 only on demand, using a dedicated "file_ra" slab.
>>        64bits machines handling lot of sockets can save about 72 byt=
es per file.
>>* private_data : The field is moved close to f_count and f_op fields =
to speedup sockfd_lookups
>=20
>=20
> Why not keep the comment or fix it?
>=20

You mean the comment in include/linux/fs.h : /* needed for tty driver, =
and maybe others */ ?

I think this comment is outdated, since nearly every 'struct file' user=
 store something of his own in this place, not only 'tty drivers'

As no other fields has comment, why should we keep this outdated commen=
t ?

Eric
