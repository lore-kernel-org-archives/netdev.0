From: Boaz Harrosh <openosd@gmail.com>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for uninitizlized
 variable expire
Date: Tue, 02 Sep 2014 13:52:15 +0300
Message-ID: <5405A15F.2060002@gmail.com>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com> <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	William Andros Adamson <andros@netapp.com>,
	Jeffrey Layton <jlayton@primarydata.com>,
	"David S. Miller" <davem@davemloft.net>,
	Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
	Shakil A Khan <shakilk1729@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/01/2014 04:50 PM, Trond Myklebust wrote:
> On Mon, Sep 1, 2014 at 7:32 AM, Shakil A Khan <shakilk1729@gmail.com> wrote:
>> Signed-off-by : Shakil A Khan <shakilk1729@gmail.com>
>> ---
>>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
>> index afb292c..bea0951 100644
>> --- a/net/sunrpc/auth_gss/auth_gss.c
>> +++ b/net/sunrpc/auth_gss/auth_gss.c
>> @@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
>>         struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
>>         struct gss_cl_ctx *ctx;
>>         unsigned long now = jiffies;
>> -       unsigned long expire;
>> +       unsigned long expire = 0;
>>
>>         rcu_read_lock();
>>         ctx = rcu_dereference(gss_cred->gc_ctx);
>> --
>> 1.7.1
> 
> That would be a compiler bug, not a kernel bug. The kernel code is
> perfectly correct as it stands, and will never access the
> uninitialised variable.
> 

Than you will need the infamous uninitialised_var()

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index afb292c..bea0951 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 	struct gss_cl_ctx *ctx;
 	unsigned long now = jiffies;
-	unsigned long expire;
+	unsigned long uninitialised_var(expire);
 
 	rcu_read_lock();
 	ctx = rcu_dereference(gss_cred->gc_ctx);

Cheers
Boaz
