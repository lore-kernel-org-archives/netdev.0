From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Mon, 2 Feb 2015 08:15:34 -0800
Message-ID: <CA+mtBx--x_BjWrvGrZBXKJDXkKKBsre7j7wqipSwXUvqcw6Cbw@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx_z3trTkK2qnVboXv7sJNjMHLr9V+4A=aFqyMo_0p1_Eg@mail.gmail.com>
	<CAEP_g=-sVSwewV=7qAYQNtBRVSrUOAjNCpfwniNq_WPg2FVpFA@mail.gmail.com>
	<CA+mtBx87bZBnY_9cgQ7k=xsD0VGZUt0rc9DjhSqhpeH3LZiuFw@mail.gmail.com>
	<CAEP_g=-Yn849TmrN5xFLJVxuux0fBuYGFSM7K-psg=pdxgPR9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34777 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbbBBQPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 11:15:35 -0500
Received: by mail-ie0-f171.google.com with SMTP id tr6so18529152ieb.2
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 08:15:34 -0800 (PST)
In-Reply-To: <CAEP_g=-Yn849TmrN5xFLJVxuux0fBuYGFSM7K-psg=pdxgPR9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is my data running STT and comparing against VXLAN, GUE, and
native (no encapsulation). This is using bnx2x.

TCP_STREAM IPv4 1 connection
  STT
    2.33% TX CPU utilization
    3.63% RX CPU utilization
    8790 Mbps
  GRE/GUE (RCO, GSO, GRO)
    5.55% TX CPU utilization
    6.67% RX CPU utilization
    9106 Mbps
  VXLAN (RCO, GSO, GRO)
    5.07% TX CPU utilization
    5.95% RX CPU utilization
    9061 Mbps
  Native (no ecapsulation)
    2.48% TX CPU utilization
    3.96% RX CPU utilization
    9411 Mbps

TCP_STREAM IPv4 200 connections
  STT
    8.36% TX CPU utilization
    9.29% RX CPU utilization
    9389 Mbps
  GUE/GRE (RCO, GSO, GRO)
    9.98% TX CPU utilization
    13.69% RX CPU utilization
    9132 Mbps
  VXLAN (RCO, GSO, GRO)
    11.79% TX CPU utilization
    13.88% RX CPU utilization
    9093 Mbps
  Native (no ecapsulation)
    6.05% TX CPU utilization
    7.27% RX CPU utilization
    9378 Mbps

TCP_RR IPv4 200 connections
  STT
    41.91% CPU utilization
    345/406/594 90/95/99% latencies
    562560 tps
  GUE/GRE (RCO, GSO, GRO)
    93.03% CPU utilization
    160/255/467 90/95/99% latencies
    1.1401e+06 tps
  VXLAN (RCO, GSO, GRO)
    93.73% CPU utilization
    157/249/448 90/95/99% latencies
    1.15655e+06 tps
  Native (no ecapsulation)
    87.46% CPU utilization
    120/178/292 90/95/99% latencies
    1.51747e+06 tps
