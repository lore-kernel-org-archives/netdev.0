From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 10:52:48 +0200
Message-ID: <CACT4Y+br2-Td8GF=eJh0SE+b1izgHy4w0btVy4JjAtuuyfAR1Q@mail.gmail.com>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150921222538.GA31246@pox.localdomain> <1442876618.29850.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150922081958.GC13047@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	ktsan@googlegroups.com, Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150922081958.GC13047@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2015 at 10:19 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/21/15 at 04:03pm, Eric Dumazet wrote:
>> What I said is :
>>
>> In @head you already have the correct nulls value, from hash table.
>>
>> You do not need to recompute this value, and/or test if hash table c=
hain
>> is empty.
>>
>> If hash bucket is empty, it contains the appropriate NULLS value.
>>
>> If you are paranoiac add this debugging check :
>>
>> if (rht_is_a_nulls(head))
>>     BUG_ON(head !=3D (struct rhash_head *)rht_marker(ht, new_hash));
>>
>>
>> Therefore, simply fix the bug and unnecessary code with :
>
> You are absolutely right Eric. Do you want to revise your patch Dmitr=
y?
> Eric's proposed fix absolutely the best way to fix this.

Mailed v2 of the patch.

--=20
Dmitry Vyukov, Software Engineer, dvyukov@google.com
Google Germany GmbH, Dienerstra=C3=9Fe 12, 80331, M=C3=BCnchen
Gesch=C3=A4ftsf=C3=BChrer: Graham Law, Christine Elizabeth Flores
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat
sind, leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen =
Dank.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.
