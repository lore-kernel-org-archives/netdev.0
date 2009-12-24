From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK) interface. (v3)
Date: Thu, 24 Dec 2009 05:38:30 +0100
Message-ID: <m2pr653s1l.fsf@ssh.synack.fr>
References: <20091224014454.GA24161@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-15?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091224014454.GA24161@heat> (Michael Stone's message of "Wed,
	23 Dec 2009 20:44:54 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <michael@laptop.org> writes:

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index f2f842d..0c65c55 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1402,6 +1402,8 @@ struct task_struct {
>   	unsigned int sessionid;
>   #endif
>   	seccomp_t seccomp;
> +/* Flags for limiting networking via prctl(PR_SET_NETWORK). */
> +  unsigned long network;
>   
>   /* Thread group tracking */
>      	u32 parent_exec_id;

I think this is unnecessary, as LSM module, you should use the
void* security member of the structure cred. 

this member allows you to mark task_struct as you which, it's a kind of
abstraction provided to all security modules.
