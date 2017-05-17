From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [PATCH v1] samples/bpf: Add a .gitignore for binaries
Date: Wed, 17 May 2017 10:18:44 +0200
Message-ID: <20170517081844.GA4447@gmail.com>
References: <20170212212356.11675-1-mic@digikod.net>
 <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
 <bd91cc8d-4683-4c4c-e672-7dce5da28183@digikod.net>
 <ad02fd5c-6812-8f1b-b348-b2ec81b9524b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ad02fd5c-6812-8f1b-b348-b2ec81b9524b@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 04:27:36PM -0700, David Ahern wrote:
> 
> The problem stems from the fact that bpf samples do not really fall into
> the 'hostprogs' category (see "4 Host Program support" in
> Documentation/kbuild/makefiles.txt). Fixing samples/bpf to not rely on
> it is the better long term solution. Building of tools/ for example does
> not rely on it so there is an existing example of leveraging kernel
> headers without the overhead.
+1

I have looked into this but found it to be not easy and all attempts to
change the Makefile has resulted in obscure errors :/

Getting clang to output in a different directory was easy[0], but I guess
this is not the right approach either. Have you tried making the change?


[0]:
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 6c7468eb3684..79268d310ba5 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -1,6 +1,13 @@
 # kbuild trick to avoid linker error. Can be omitted if a module is built.
 obj- := dummy.o
 
+ifndef O
+  OUTPUT := $(shell pwd)/samples/bpf/_build/
+else
+  OUTPUT := $O/
+endif
+$(shell mkdir -p $(OUTPUT))
+
 # List of programs to build
 hostprogs-y := test_lru_dist
 hostprogs-y += sock_example
@@ -190,4 +197,4 @@ $(obj)/%.o: $(src)/%.c
 		-Wno-gnu-variable-sized-type-not-at-end \
 		-Wno-address-of-packed-member -Wno-tautological-compare \
 		-Wno-unknown-warning-option \
-		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
+		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $(OUTPUT)$(shell basename $@)

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
