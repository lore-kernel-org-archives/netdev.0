From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Wed, 30 Mar 2005 10:16:47 -0700
Message-ID: <20050330171647.GC30849@colo.lackof.org>
References: <1112138018.1088.31.camel@jzny.localdomain> <E1DGSwp-0004ZE-00@thunker.thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, "'Rick Jones'" <rick.jones2@hp.com>,
        "'netdev'" <netdev@oss.sgi.com>, ksummit-2005-discuss@thunk.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Aizman <itn780@yahoo.com>
Content-Disposition: inline
In-Reply-To: <E1DGSwp-0004ZE-00@thunker.thunk.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 06:28:25PM -0800, Alex Aizman wrote:
> If we continue to fall back into TCP-will-eventually-recover mentality
> iSCSI, or at least a "soft" non-offloaded iSCSI over regular non-TOE TCP,
> will not be able to compete with FC, which uses determinstic credit-based
> flow control. That non-determinism is a bigger issue, while a corner case
> like swap device happenning to be iSCSI-remote is just that, a corner case
> that helps to highlight and bring the general problem to the foreground.

There is no way to fix the "non-determinism" inherent in a transport.
DoS attacks depend on this.  The transport has to be deterministic
(flow control, QoS) to avoid anything that looks like a DoS (e.g. OOM).

Parallel SCSI suffers the same problem. The priority on the transport
is dictated by SCSI ID. Low priority SCSI IDs can (and do) get starved
with as few as 5 RAID storage enclosures.  The problem is the initiator
(host controller) can send data but then like iSCSI, the command times
out when the completion doesn't arrive. For parallel SCSI, the SCSI target
device never wins SCSI bus arbitration to send back the completion.

People can configure the system so this isn't a problem.
But it means not having as much storage per SCSI bus.

hth,
grant
