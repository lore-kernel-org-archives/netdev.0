From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 20/24] bpf: Restrict kernel image access functions when the kernel is locked down
Date: Thu, 13 Apr 2017 09:46:18 +0100
Message-ID: <15283.1492073178@warthog.procyon.org.uk>
References: <20170406122907.GA53880@ast-mbp.thefacebook.com> <149142326734.5101.4596394505987813763.stgit@warthog.procyon.org.uk> <149142344547.5101.4518618716303032193.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
        linux-efi@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk,
        netdev@vger.kernel.org, Chun-Yi Lee <jlee@suse.com>,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
        gregkh@linuxfoundation.org, matthew.garrett@nebula.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170406122907.GA53880@ast-mbp.thefacebook.com>
Content-ID: <15282.1492073178.1@warthog.procyon.org.uk>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> this will obviously break the program.

Yeah.  But if it allows one to twiddle the kernel image or gain access to
crypto material...

> How about disabling loading tracing programs during the lockdown completely?

Interesting thought.  I'm not sure how much would actually need locking down
here.  Turning on tracepoints in the kernel and reading out of the trace
buffer, for example, ought to be okay, though if there are any tracepoints
that leak crypto information, they may need locking down also.

Basically, I think it boils down to: if it can be used to modify the kernel
image or read arbitrary data from the kernel image then should probably be
forbidden.  There have to be exceptions, though, such as loading authenticated
kernel modules.

David
