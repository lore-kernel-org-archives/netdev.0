From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/4] Fix the NetLabel LSM category mappings
Date: Thu, 31 Jul 2014 15:47:29 -0700
Message-ID: <53DAC781.3010502@schaufler-ca.com>
References: <20140731212856.4991.49396.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Christian Evans <frodox@zoho.com>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20140731212856.4991.49396.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/31/2014 2:44 PM, Paul Moore wrote:
> As you will see in the patch descriptions below, the NetLabel LSM
> category mappings are very badly broken.  This patchset should repair
> things and make life better in the future.  The first three patches
> are straight-up bug fixes; the fourth patch doesn't actually fix any
> faulty logic in the code, but rather shortens some stupidly long
> function and structure names relating to the NetLabel category
> mappings.  I should probably do something similar with a lot of other
> NetLabel APIs, but that is for another time.
>
> Thanks to Christian Evans for pointing out one of the original
> problems.  I don't think he realized how many problems there really
> were, but I still owe him one for getting me to revisit this ugly,
> nasty code.  I apologize it took so long to get a fix out and that
> things were broken this badly in the first place.
>
> Casey, I'm CC'ing you here because this patchset does touch some of
> the Smack code, but as you can see the changes are trivial.  I will
> be very surprised if you find anything objectionable in there.
> However, if you do, let me know and I'll fix it.

The code passes my tests. I'll mark the patches "Tested-by:".

> DaveM/netdev folks, you guys are included here for the obvious reason
> that a good chunk of the code changes live in net/*.  However, the
> net/* related changes are all within the NetLabel code and not in the
> core networking stack so I doubt this is something you'll care too
> much about.  I'm going to guess that as far as you're concerned, this
> is just another bugfix to a subsystem you don't really care about.
>
> DaveM, unless you have any objections, I'm planning on pushing this
> via the SELinux tree up through James' LSM tree since that seems to
> make the most sense to me.  If you would rather push it via the netdev
> tree please let me know.
>
> -Paul
>
> ---
>
> Paul Moore (4):
>       netlabel: fix a problem when setting bits below the previously lowest bit
>       netlabel: fix the horribly broken catmap functions
>       netlabel: fix the catmap walking functions
>       netlabel: shorter names for the NetLabel catmap funcs/structs
>
>
>  include/net/netlabel.h        |   94 +++++++-----
>  net/ipv4/cipso_ipv4.c         |   47 ++----
>  net/netlabel/netlabel_kapi.c  |  327 ++++++++++++++++++++++++++++-------------
>  security/selinux/ss/ebitmap.c |  133 +++++++----------
>  security/selinux/ss/ebitmap.h |    8 +
>  security/smack/smack_access.c |   11 +
>  security/smack/smack_lsm.c    |    6 -
>  security/smack/smackfs.c      |   14 +-
>  8 files changed, 366 insertions(+), 274 deletions(-)
>

