From: "Dorau, Lukasz" <lukasz.dorau@intel.com>
Subject: Cannot attach BPF to tracepoints
Date: Fri, 10 Mar 2017 13:49:20 +0000
Message-ID: <D9FFE20C522965449E182ACE73889AEB48681EB1@irsmsx105.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jelinek, Sarah" <sarah.jelinek@intel.com>,
        "Slusarz, Marcin" <marcin.slusarz@intel.com>,
        "Chernookyi, Vitalii" <vitalii.chernookyi@intel.com>,
        "Buella, Gabor" <gabor.buella@intel.com>,
        "Lebioda, Pawel" <pawel.lebioda@intel.com>,
        "goldshtn@gmail.com" <goldshtn@gmail.com>,
        "bgregg@netflix.com" <bgregg@netflix.com>
To: Alexei Starovoitov <ast@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-trace-users-owner@vger.kernel.org"
        <linux-trace-users-owner@vger.kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I cannot attach BPF to tracepoints.

I used bcc's (https://github.com/iovisor/bcc) trace.py tool:
https://github.com/iovisor/bcc/blob/master/tools/trace.py
to test this issue:

# /usr/share/bcc/tools/trace t:syscalls:sys_enter_open
ioctl(PERF_EVENT_IOC_SET_BPF): Invalid argument
Failed to attach BPF to tracepoint

# /usr/share/bcc/tools/trace t:syscalls:sys_exit_open
ioctl(PERF_EVENT_IOC_SET_BPF): Invalid argument
Failed to attach BPF to tracepoint

However it is possible to attach BPF to raw tracepoints:
# /usr/share/bcc/tools/trace t:raw_syscalls:sys_enter
# /usr/share/bcc/tools/trace t:raw_syscalls:sys_exit

and to kprobes:
# /usr/share/bcc/tools/trace 'sys_open "%s", arg1'
# /usr/share/bcc/tools/trace 'r::sys_open "%s", arg1'

Can it be a bug in BPF code?

Regards,
Lukasz
