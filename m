From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Thu, 31 Dec 2009 08:48:45 -0800
Message-ID: <m18wcjnl76.fsf@fess.ebiederm.org>
References: <m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	<m1r5qdt721.fsf@fess.ebiederm.org>
	<3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
	<m1d41w62zc.fsf_-_@fess.ebiederm.org>
	<551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com> <m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com>
	<m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	<20091231152523.GA12969@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrew G. Morgan" <morgan@kernel.org>,
	Bryan Donlan <bdonlan@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.c
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091231152523.GA12969@us.ibm.com> (Serge E. Hallyn's message of "Thu\, 31 Dec 2009 09\:25\:23 -0600")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

>> diff --git a/security/commoncap.c b/security/commoncap.c
>> index f800fdb..34500e3 100644
>> --- a/security/commoncap.c
>> +++ b/security/commoncap.c
>> @@ -389,7 +389,7 @@ static int get_file_caps(struct linux_binprm *bprm, bool *effective)
>>  	if (!file_caps_enabled)
>>  		return 0;
>> 
>> -	if (bprm->file->f_vfsmnt->mnt_flags & MNT_NOSUID)
>> +	if (bprm->nosuid)
>>  		return 0;
>
> I'm sorry, this may actually not be sufficient.
>
> Could you try the following test on a kernel with this patch? :
>
> 1. become root
> 2. do prctl(PR_SET_NOSUID);
> 3. run bash, and examine your capabilities in /proc/self/status
>
> I think the code in security/commoncap.c:457-458 will re-raise your
> capabilities.

Right.  That is a legitimate issue.
I almost guard against it with my test against with my start condition test
of cap_isclear(cred->cap_permitted).

Which causes this to fail for root in most situations.  I will add a
test for the securebits, and deny this to root unless the securebits
are such that root cannot gain privilege.

Thanks for catching this.  I figured I might need a uid == 0 exclusion.
Where the test was split when I wrote it I wasn't certain where to put it.

Eric
