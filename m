From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 2/8] S2io: sw bug fixes
Date: Wed, 6 Oct 2004 18:23:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <006201c4ac0c$3e3da970$9810100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached is the second patch in this submission. It contains the following
software bug fixes.

1. In free_rx_buffers clearing out RxDs not owned by Xena.

2. In alarm_intr_handler, when a serr error occurs, schedule a task to reset
the card rather than stopping Tx queue.

3. In s2io_close freeing IRQ before calling s2io_reset also added a new call
to flush queued tasks. This is not done if the s2io_close itself is called
from a queued task like s2io_restart_nic.

4. read_eeprom function has been changed such that data to be returned is
sent as an input argument and the return value represents a pass/fail. The
previous implementation as Randy had pointed out was error prone as on
failure it returned -1 which can be interpreted as all ff's, so any data
area which contained ff's in the eeprom was likely to be treated as an
error.

5. Added a flag "task_flag" to track if the call to s2io_close is coming
from the s2io_restart_nic function or from the ifconfig <I/F> down called by
user.

6. Moved register_netdev call from just after setting entry points to the
end of the s2io_init_nic function.

7. In s2io.h field added a new member into the s2io_nic structure called
"task_flag".

Thanks,
Ravi
