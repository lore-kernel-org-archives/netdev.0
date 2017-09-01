From: Tim Sander <tim@krieglstein.org>
Subject: ptp device strangeness
Date: Fri, 01 Sep 2017 17:28:34 +0200
Message-ID: <1934181.WnEexch2hB@dabox>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I am currently using ptp on a Altera/Intel SOC with a dp8640 PHY.
PTP functionality seems to be right. But i am doing timestamping
with gpio0 and sometimes i loose the sync of the stamping and
the events. So i would like to read out all messages. Reading O_NONBLOCK
does not work so i tried polling from usermode with the below code:

		np = poll(&ev, 1, 0);
		ev.fd=ptpDev;
		ev.events = POLLIN;
		if (np>0) {
			if (ev.revents>0) {
				std::cout<<"discarded ptp event"<<std::endl;
				read(ptpDev, &event, sizeof(event));
			}
But as confirmed in the debugger np=1 and read blocks forever.
I don't think that this is correct behavior?

For pinning down this misbehavior I would like to know it this is a local 
problem of my hardware or if this is a general problem with the ptp chardev 
interface? 

I am currently on 4.11.12. As this is the latest preempt rt release.

Best regards
Tim
