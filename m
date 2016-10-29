From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Date: Sat, 29 Oct 2016 11:05:28 -0700
Message-ID: <1477764328.7065.284.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
         <CAM_iQpX_xw35MUyd9aON5U=HmUoRafeoOF+_vSTHGYnrXd-CHg@mail.gmail.com>
         <CAAeHK+y9ENvGzJEQtRy_5DEzCfhGEYXR5CPpgwXy_FoOtFUf3Q@mail.gmail.com>
         <1477762981.7065.272.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+x6+CU+1KJNOpnoyyZoqH7_dcrWFVGU1KrJYVwJSzdxPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+x6+CU+1KJNOpnoyyZoqH7_dcrWFVGU1KrJYVwJSzdxPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-10-29 at 19:59 +0200, Andrey Konovalov wrote:
> Hi Eric,
> 
> Tested with both patches applied, still seeing the warning.
> 
> Thanks!

Arg, sorry, this was at the wrong place.

Thanks for testing !

diff --git a/net/dccp/output.c b/net/dccp/output.c
index b66c84db0766..2548edff86ff 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -224,6 +224,11 @@ static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
 
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	sk->sk_write_pending++;
+
+	/* release_sock()/lock_sock() will process socket backlog
+	 * from process context. Be prepared to sleep !
+	 */
+	sched_annotate_sleep();
 	release_sock(sk);
 
 	remaining = schedule_timeout(delay);
