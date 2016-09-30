From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] qed: remove unused function in qed_cxt.c
Date: Fri, 30 Sep 2016 16:29:03 +0200
Message-ID: <201609301629.03359.arnd@arndb.de>
References: <1475222574-19280-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475222574-19280-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 September 2016, Baoyou Xie wrote:
> We get 3 warnings when building kernel with W=1:
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:1941:1: warning: no previous prototype for 'qed_cxt_dynamic_ilt_alloc' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:2158:5: warning: no previous prototype for 'qed_cxt_free_proto_ilt' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:2186:5: warning: no previous prototype for 'qed_cxt_get_task_ctx' [-Wmissing-prototypes]
> 
> In fact, these functions are unused in
> drivers/net/ethernet/qlogic/qed/qed_cxt.c, but should be removed.
> 
> So this patch removes these unused functions.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

These were only recently added in dbb799c39717 ("qed: Initialize hardware for new protocols"),
so it's likely that the plan is to use them in the future, and your commit message should
at least mention that.

If there is no longer a plan to use them, it would probably better to back out that whole
patch, other alternatives in this case might be to mark them as "static __maybe_unused"
so the compiler can drop the code silently, or to add declarations in a header if the
user would be in another file.

	Arnd
