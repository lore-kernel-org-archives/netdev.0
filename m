From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/2] bpf: add a bpf_override_function helper
Date: Thu, 02 Nov 2017 02:08:10 +0100
Message-ID: <59FA6FFA.1080503@iogearbox.net>
References: <1509555643-2899-1-git-send-email-josef@toxicpanda.com> <1509555643-2899-2-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>
To: Josef Bacik <josef@toxicpanda.com>, rostedt@goodmis.org,
        mingo@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509555643-2899-2-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2017 06:00 PM, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
>
> Error injection is sloppy and very ad-hoc.  BPF could fill this niche
> perfectly with it's kprobe functionality.  We could make sure errors are
> only triggered in specific call chains that we care about with very
> specific situations.  Accomplish this with the bpf_override_funciton
> helper.  This will modify the probe'd callers return value to the
> specified value and set the PC to an override function that simply
> returns, bypassing the originally probed function.  This gives us a nice
> clean way to implement systematic error injection for all of our code
> paths.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Looks useful (seccomp/BPF has something similar but on syscall level).
I think given we change kernel behavior, it would be good if we emit
similar warning like in case of bpf_get_probe_write_proto(), such that
from staring at the log (e.g. in case of subsequent crash), it could
help identifying that cause to trigger the bug could have been due to
bpf_override_function().
