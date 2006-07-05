From: Phil Oester <kernel@linuxace.com>
Subject: e1000 TX unit hang
Date: Wed, 5 Jul 2006 09:33:32 -0700
Message-ID: <20060705163332.GA17915@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:45836
	"HELO linuxace.com") by vger.kernel.org with SMTP id S964860AbWGEQdc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 12:33:32 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I saw this error (once) in 2.6.13 a few weeks ago:

Jun 23 15:19:01 X kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Jun 23 15:19:01 X kernel:   TDH                  <7e>
Jun 23 15:19:01 X kernel:   TDT                  <7f>
Jun 23 15:19:01 X kernel:   next_to_use          <7f>
Jun 23 15:19:01 X kernel:   next_to_clean        <7e>
Jun 23 15:19:01 X kernel: buffer_info[next_to_clean]
Jun 23 15:19:01 X kernel:   dma                  <16ef9012>
Jun 23 15:19:01 X kernel:   time_stamp           <423845db>
Jun 23 15:19:01 X kernel:   next_to_watch        <7e>
Jun 23 15:19:01 X kernel:   jiffies              <423845db>
Jun 23 15:19:01 X kernel:   next_to_watch.status <0>

so upgraded to 2.6.17 and got a slew of them today - shown below.
E1000 maintainers: any ideas?

Phil
  


Jul  5 11:43:26 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:26 X kernel:   Tx Queue             <0>
Jul  5 11:43:26 X kernel:   TDH                  <a>
Jul  5 11:43:26 X kernel:   TDT                  <a>
Jul  5 11:43:26 X kernel:   next_to_use          <a>
Jul  5 11:43:26 X kernel:   next_to_clean        <5f>
Jul  5 11:43:26 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:26 X kernel:   time_stamp           <b6bc51>
Jul  5 11:43:26 X kernel:   next_to_watch        <5f>
Jul  5 11:43:26 X kernel:   jiffies              <b6bcc6>
Jul  5 11:43:26 X kernel:   next_to_watch.status <1>

Jul  5 11:43:33 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:34 X kernel:   Tx Queue             <0>
Jul  5 11:43:36 X kernel:   TDH                  <2c>
Jul  5 11:43:38 X kernel:   TDT                  <2c>
Jul  5 11:43:42 X kernel:   next_to_use          <2c>
Jul  5 11:43:45 X kernel:   next_to_clean        <81>
Jul  5 11:43:46 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:47 X kernel:   time_stamp           <b6be88>
Jul  5 11:43:49 X kernel:   next_to_watch        <81>
Jul  5 11:43:52 X kernel:   jiffies              <b6bf0e>
Jul  5 11:43:53 X kernel:   next_to_watch.status <1>

Jul  5 11:43:53 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:53 X kernel:   Tx Queue             <0>
Jul  5 11:43:53 X kernel:   TDH                  <ff>
Jul  5 11:43:53 X kernel:   TDT                  <ff>
Jul  5 11:43:53 X kernel:   next_to_use          <ff>
Jul  5 11:43:53 X kernel:   next_to_clean        <54>
Jul  5 11:43:53 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:53 X kernel:   time_stamp           <b6c06d>
Jul  5 11:43:53 X kernel:   next_to_watch        <54>
Jul  5 11:43:53 X kernel:   jiffies              <b6c0d2>
Jul  5 11:43:53 X kernel:   next_to_watch.status <1>

Jul  5 11:43:53 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:53 X kernel:   Tx Queue             <0>
Jul  5 11:43:53 X kernel:   TDH                  <81>
Jul  5 11:43:53 X kernel:   TDT                  <81>
Jul  5 11:43:53 X kernel:   next_to_use          <81>
Jul  5 11:43:53 X kernel:   next_to_clean        <d6>
Jul  5 11:43:53 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:53 X kernel:   time_stamp           <b6c0b8>
Jul  5 11:43:53 X kernel:   next_to_watch        <d6>
Jul  5 11:43:53 X kernel:   jiffies              <b6c19b>
Jul  5 11:43:53 X kernel:   next_to_watch.status <1>

Jul  5 11:43:53 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:53 X kernel:   Tx Queue             <0>
Jul  5 11:43:53 X kernel:   TDH                  <1b>
Jul  5 11:43:53 X kernel:   TDT                  <1b>
Jul  5 11:43:53 X kernel:   next_to_use          <1b>
Jul  5 11:43:53 X kernel:   next_to_clean        <71>
Jul  5 11:43:53 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:53 X kernel:   time_stamp           <b6c1d8>
Jul  5 11:43:53 X kernel:   next_to_watch        <71>
Jul  5 11:43:53 X kernel:   jiffies              <b6c255>
Jul  5 11:43:53 X kernel:   next_to_watch.status <1>

Jul  5 11:43:53 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:53 X kernel:   Tx Queue             <0>
Jul  5 11:43:53 X kernel:   TDH                  <9e>
Jul  5 11:43:53 X kernel:   TDT                  <9e>
Jul  5 11:43:53 X kernel:   next_to_use          <9e>
Jul  5 11:43:54 X kernel:   next_to_clean        <f3>
Jul  5 11:43:54 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:54 X kernel:   time_stamp           <b6c229>
Jul  5 11:43:54 X kernel:   next_to_watch        <f3>
Jul  5 11:43:54 X kernel:   jiffies              <b6c329>
Jul  5 11:43:54 X kernel:   next_to_watch.status <1>

Jul  5 11:43:54 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:54 X kernel:   Tx Queue             <0>
Jul  5 11:43:54 X kernel:   TDH                  <39>
Jul  5 11:43:54 X kernel:   TDT                  <39>
Jul  5 11:43:54 X kernel:   next_to_use          <39>
Jul  5 11:43:54 X kernel:   next_to_clean        <8e>
Jul  5 11:43:54 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:54 X kernel:   time_stamp           <b6c4a0>
Jul  5 11:43:54 X kernel:   next_to_watch        <8e>
Jul  5 11:43:54 X kernel:   jiffies              <b6c558>
Jul  5 11:43:54 X kernel:   next_to_watch.status <1>

Jul  5 11:43:54 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:54 X kernel:   Tx Queue             <0>
Jul  5 11:43:54 X kernel:   TDH                  <7e>
Jul  5 11:43:54 X kernel:   TDT                  <7e>
Jul  5 11:43:54 X kernel:   next_to_use          <7e>
Jul  5 11:43:54 X kernel:   next_to_clean        <d3>
Jul  5 11:43:54 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:54 X kernel:   time_stamp           <b6c5aa>
Jul  5 11:43:54 X kernel:   next_to_watch        <d3>
Jul  5 11:43:54 X kernel:   jiffies              <b6c651>
Jul  5 11:43:54 X kernel:   next_to_watch.status <1>

Jul  5 11:43:54 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:43:54 X kernel:   Tx Queue             <0>
Jul  5 11:43:54 X kernel:   TDH                  <7e>
Jul  5 11:43:54 X kernel:   TDT                  <7e>
Jul  5 11:43:54 X kernel:   next_to_use          <7e>
Jul  5 11:43:54 X kernel:   next_to_clean        <14>
Jul  5 11:43:54 X kernel: buffer_info[next_to_clean]
Jul  5 11:43:54 X kernel:   time_stamp           <b6c5aa>
Jul  5 11:43:54 X kernel:   next_to_watch        <14>
Jul  5 11:43:54 X kernel:   jiffies              <b6c725>
Jul  5 11:43:54 X kernel:   next_to_watch.status <1>

Jul  5 11:49:35 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:49:35 X kernel:   Tx Queue             <0>
Jul  5 11:49:35 X kernel:   TDH                  <d5>
Jul  5 11:49:35 X kernel:   TDT                  <d5>
Jul  5 11:49:35 X kernel:   next_to_use          <d5>
Jul  5 11:49:35 X kernel:   next_to_clean        <2a>
Jul  5 11:49:35 X kernel: buffer_info[next_to_clean]
Jul  5 11:49:35 X kernel:   time_stamp           <b74c13>
Jul  5 11:49:35 X kernel:   next_to_watch        <2a>
Jul  5 11:49:35 X kernel:   jiffies              <b74ca6>
Jul  5 11:49:38 X kernel:   next_to_watch.status <1>

Jul  5 11:49:49 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:49:51 X kernel:   Tx Queue             <0>
Jul  5 11:49:59 X kernel:   TDH                  <5f>
Jul  5 11:50:01 X kernel:   TDT                  <5f>
Jul  5 11:50:04 X kernel:   next_to_use          <5f>
Jul  5 11:50:04 X kernel:   next_to_clean        <b4>
Jul  5 11:50:04 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:04 X kernel:   time_stamp           <b74d69>
Jul  5 11:50:04 X kernel:   next_to_watch        <b4>
Jul  5 11:50:04 X kernel:   jiffies              <b74e22>
Jul  5 11:50:04 X kernel:   next_to_watch.status <1>

Jul  5 11:50:04 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:04 X kernel:   Tx Queue             <0>
Jul  5 11:50:04 X kernel:   TDH                  <e1>
Jul  5 11:50:04 X kernel:   TDT                  <e1>
Jul  5 11:50:04 X kernel:   next_to_use          <e1>
Jul  5 11:50:04 X kernel:   next_to_clean        <36>
Jul  5 11:50:04 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:04 X kernel:   time_stamp           <b74deb>
Jul  5 11:50:04 X kernel:   next_to_watch        <36>
Jul  5 11:50:04 X kernel:   jiffies              <b74ee4>
Jul  5 11:50:04 X kernel:   next_to_watch.status <1>

Jul  5 11:50:04 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:04 X kernel:   Tx Queue             <0>
Jul  5 11:50:05 X kernel:   TDH                  <a8>
Jul  5 11:50:05 X kernel:   TDT                  <a8>
Jul  5 11:50:05 X kernel:   next_to_use          <a8>
Jul  5 11:50:05 X kernel:   next_to_clean        <fd>
Jul  5 11:50:05 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:05 X kernel:   time_stamp           <b74f0a>
Jul  5 11:50:05 X kernel:   next_to_watch        <fd>
Jul  5 11:50:05 X kernel:   jiffies              <b74fbf>
Jul  5 11:50:05 X kernel:   next_to_watch.status <1>

Jul  5 11:50:05 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:05 X kernel:   Tx Queue             <0>
Jul  5 11:50:05 X kernel:   TDH                  <a8>
Jul  5 11:50:05 X kernel:   TDT                  <a8>
Jul  5 11:50:05 X kernel:   next_to_use          <a8>
Jul  5 11:50:05 X kernel:   next_to_clean        <3e>
Jul  5 11:50:05 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:05 X kernel:   time_stamp           <b74f0a>
Jul  5 11:50:05 X kernel:   next_to_watch        <3e>
Jul  5 11:50:05 X kernel:   jiffies              <b7508d>
Jul  5 11:50:05 X kernel:   next_to_watch.status <1>

Jul  5 11:50:05 X kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:05 X kernel:   Tx Queue             <0>
Jul  5 11:50:05 X kernel:   TDH                  <47>
Jul  5 11:50:05 X kernel:   TDT                  <47>
Jul  5 11:50:05 X kernel:   next_to_use          <47>
Jul  5 11:50:05 X kernel:   next_to_clean        <ff>
Jul  5 11:50:05 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:05 X kernel:   time_stamp           <b751d5>
Jul  5 11:50:05 X kernel:   next_to_watch        <ff>
Jul  5 11:50:05 X kernel:   jiffies              <b75253>
Jul  5 11:50:05 X kernel:   next_to_watch.status <1>

Jul  5 11:50:05 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:05 X kernel:   Tx Queue             <0>
Jul  5 11:50:05 X kernel:   TDH                  <b0>
Jul  5 11:50:05 X kernel:   TDT                  <b0>
Jul  5 11:50:05 X kernel:   next_to_use          <b0>
Jul  5 11:50:05 X kernel:   next_to_clean        <5>
Jul  5 11:50:05 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:05 X kernel:   time_stamp           <b750fd>
Jul  5 11:50:05 X kernel:   next_to_watch        <5>
Jul  5 11:50:05 X kernel:   jiffies              <b752a6>
Jul  5 11:50:05 X kernel:   next_to_watch.status <1>

Jul  5 11:50:05 X kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:05 X kernel:   Tx Queue             <0>
Jul  5 11:50:05 X kernel:   TDH                  <47>
Jul  5 11:50:05 X kernel:   TDT                  <47>
Jul  5 11:50:05 X kernel:   next_to_use          <47>
Jul  5 11:50:05 X kernel:   next_to_clean        <40>
Jul  5 11:50:05 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:05 X kernel:   time_stamp           <b75225>
Jul  5 11:50:05 X kernel:   next_to_watch        <40>
Jul  5 11:50:05 X kernel:   jiffies              <b752f2>
Jul  5 11:50:05 X kernel:   next_to_watch.status <1>

Jul  5 11:50:05 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:05 X kernel:   Tx Queue             <0>
Jul  5 11:50:05 X kernel:   TDH                  <b0>
Jul  5 11:50:05 X kernel:   TDT                  <b0>
Jul  5 11:50:05 X kernel:   next_to_use          <b0>
Jul  5 11:50:05 X kernel:   next_to_clean        <46>
Jul  5 11:50:05 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:05 X kernel:   time_stamp           <b75173>
Jul  5 11:50:05 X kernel:   next_to_watch        <46>
Jul  5 11:50:05 X kernel:   jiffies              <b75317>
Jul  5 11:50:06 X kernel:   next_to_watch.status <1>

Jul  5 11:50:06 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:06 X kernel:   Tx Queue             <0>
Jul  5 11:50:06 X kernel:   TDH                  <c0>
Jul  5 11:50:06 X kernel:   TDT                  <c0>
Jul  5 11:50:06 X kernel:   next_to_use          <c0>
Jul  5 11:50:06 X kernel:   next_to_clean        <15>
Jul  5 11:50:06 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:06 X kernel:   time_stamp           <b7533f>
Jul  5 11:50:06 X kernel:   next_to_watch        <15>
Jul  5 11:50:06 X kernel:   jiffies              <b753ef>
Jul  5 11:50:06 X kernel:   next_to_watch.status <1>

Jul  5 11:50:06 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:06 X kernel:   Tx Queue             <0>
Jul  5 11:50:06 X kernel:   TDH                  <c0>
Jul  5 11:50:06 X kernel:   TDT                  <c0>
Jul  5 11:50:06 X kernel:   next_to_use          <c0>
Jul  5 11:50:06 X kernel:   next_to_clean        <56>
Jul  5 11:50:06 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:06 X kernel:   time_stamp           <b7533f>
Jul  5 11:50:06 X kernel:   next_to_watch        <56>
Jul  5 11:50:06 X kernel:   jiffies              <b754d3>
Jul  5 11:50:06 X kernel:   next_to_watch.status <1>

Jul  5 11:50:06 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:06 X kernel:   Tx Queue             <0>
Jul  5 11:50:06 X kernel:   TDH                  <c0>
Jul  5 11:50:06 X kernel:   TDT                  <c0>
Jul  5 11:50:06 X kernel:   next_to_use          <c0>
Jul  5 11:50:06 X kernel:   next_to_clean        <97>
Jul  5 11:50:06 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:06 X kernel:   time_stamp           <b7537a>
Jul  5 11:50:06 X kernel:   next_to_watch        <97>
Jul  5 11:50:06 X kernel:   jiffies              <b755ad>
Jul  5 11:50:06 X kernel:   next_to_watch.status <1>

Jul  5 11:50:06 X kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Jul  5 11:50:06 X kernel:   Tx Queue             <0>
Jul  5 11:50:06 X kernel:   TDH                  <36>
Jul  5 11:50:06 X kernel:   TDT                  <36>
Jul  5 11:50:06 X kernel:   next_to_use          <36>
Jul  5 11:50:06 X kernel:   next_to_clean        <8b>
Jul  5 11:50:06 X kernel: buffer_info[next_to_clean]
Jul  5 11:50:06 X kernel:   time_stamp           <b756ee>
Jul  5 11:50:06 X kernel:   next_to_watch        <8b>
Jul  5 11:50:06 X kernel:   jiffies              <b75837>
Jul  5 11:50:06 X kernel:   next_to_watch.status <1>

