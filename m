From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vfs: dont chain pipe/anon/socket on superblock
 s_inodes list
Date: Tue, 26 Jul 2011 12:43:33 +0200
Message-ID: <1311677013.2355.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110721204042.GB31405@ZenIV.linux.org.uk>
	 <1311294452.2576.18.camel@schen9-DESK>
	 <20110723132411.GA22183@infradead.org>
	 <1311633550.2576.33.camel@schen9-DESK>
	 <20110725225154.GD22133@ZenIV.linux.org.uk>
	 <1311636178.2576.34.camel@schen9-DESK>
	 <1311660013.2996.6.camel@edumazet-laptop>
	 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110726090357.GA13013@infradead.org>
	 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110726094204.GA12086@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110726094204.GA12086@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 26 juillet 2011 =C3=A0 05:42 -0400, Christoph Hellwig a =C3=A9=
crit :
> On Tue, Jul 26, 2011 at 11:36:34AM +0200, Eric Dumazet wrote:
> > [PATCH v2] vfs: dont chain pipe/anon/socket on superblock s_inodes =
list
> >=20
> > Workloads using pipes and sockets hit inode_sb_list_lock contention=
=2E
> >=20
> > superblock s_inodes list is needed for quota, dirty, pagecache and
> > fsnotify management. pipe/anon/socket fs are clearly not candidates=
 for
> > these.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Looks good to me,
>=20
> Reviewed-by: Christoph Hellwig <hch@lst.de>
>=20

Thanks !

BTW, we have one atomic op that could be avoided in new_inode()

spin_lock(&inode->i_lock);
inode->i_state =3D 0;
spin_unlock(&inode->i_lock);

can probably be changed to something less expensive...

inode->i_state =3D 0;
smp_wmb();

Not clear if we really need a memory barrier either....



--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
