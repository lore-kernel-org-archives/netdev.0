From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Resend [PATCH] netfilter: Fix copy_to_user too small size
 parametre.
Date: Sun, 4 Mar 2012 18:03:57 +0100
Message-ID: <20120304170357.GA24080@1984>
References: <1330621743-12883-1-git-send-email-santoshprasadnayak@gmail.com>
 <20120304121841.GA23277@1984>
 <CAOD=uF6UvL2oEmJmgak4X5L0PR+qQi2=Vr22AUsAxLLOfi44rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santosh prasad nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOD=uF6UvL2oEmJmgak4X5L0PR+qQi2=Vr22AUsAxLLOfi44rw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 04, 2012 at 06:09:08PM +0530, santosh prasad nayak wrote:
> where is it broken ?
> Can you please explain ?

> >> + =A0 =A0 strncpy(name, t->u.target->name, sizeof(name));
> >> =A0 =A0 =A0 hlp =3D ubase + (((char *)e + e->target_offset) - base=
);
> >> =A0 =A0 =A0 t =3D (struct ebt_entry_target *)(((char *)e) + e->tar=
get_offset);

In ebt_make_names, you dereference t but it is not initialized.

Note that strncpy refers to t->u.target->name which is initialized a
couple of lines after it.
