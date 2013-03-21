From: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
Subject: Re: [PATCH 2/2] man/send(2): document a long standing bug that can
 cause spurious EPERM errors
Date: Thu, 21 Mar 2013 14:07:02 +0900
Message-ID: <514A9576.4060902@lab.ntt.co.jp>
References: <1363675513.4767.6.camel@nexus> <1363675960.4767.10.camel@nexus> <20130319101223.GA3672@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	linux-man@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hirotaka Sasaki <sasaki.hirotaka@lab.ntt.co.jp>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130319101223.GA3672@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/03/19 19:12, Pablo Neira Ayuso wrote:
> On Tue, Mar 19, 2013 at 03:52:40PM +0900, Fernando Luis V=E1zquez Cao=
 wrote:
>> Subject: [PATCH 2/2] man/send(2): document a long standing bug that =
can cause spurious EPERM errors
>>
>> This bug has been known since early 2009 (the latest) and  discussed=
 in
>> netdev before:
>>
>> http://marc.info/?l=3Dlinux-netdev&w=3D2&r=3D1&s=3DPossible+race+con=
dition+in+conntracking+&q=3Db
>>
>> It seems that a proper fix would be non trivial, so document the bug
>> in the meantime.
>>
>> Reported-by: Hirotaka Sasaki <sasaki.hirotaka@lab.ntt.co.jp>
>> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
>> ---
>>
>> diff -urNp man-pages-3.50-orig/man2/send.2 man-pages-3.50/man2/send.=
2
>> --- man-pages-3.50-orig/man2/send.2	2013-03-19 15:18:03.784306647 +0=
900
>> +++ man-pages-3.50/man2/send.2	2013-03-19 15:30:40.788060426 +0900
>> @@ -420,6 +420,11 @@ Linux may return
>>   .B EPIPE
>>   instead of
>>   .BR ENOTCONN .
>> +
>> +Linux may return spurious
>> +.B EPERM
>> +errors when netfilter's conntrack module is loaded and two or more
>> +UDP packets belonging to the same connection are processed in paral=
lel.
> The Connection tracking system may drop packets for different reasons
> under rare circunstances, not only in this case.
> I'd prefer if you only apply patch 1/2.

I'd agree with you if we *silently* dropped packets in such
situations, but unfortunately that's not the case.

The problem is that sometimes we end up returning spurious EPERM
errors to user space. Applications may (and many actually do)
interpret EPERM as "an attempt was made to perform an operation
limited to processes with appropriate privileges or to the owner of a
file or other resource" and just bail out after seeing the first
EPERM; after all, if its cause is system policy-related there is no
point in retrying. Spurious EPERM errors would break such (perfectly
compliant) applications, so the least we can do is document them
properly.

Thanks,
=46ernando
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
