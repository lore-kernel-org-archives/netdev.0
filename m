From: "Tej Parkash" <tejparkash.d@gmail.com>
Subject: extra layer below inet layer.
Date: Thu, 7 Jun 2007 10:10:44 +0530
Message-ID: <2bd9ebfa0706062140vfddf3etfc8fd17749c9ad12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:9895 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809AbXFGEkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 00:40:45 -0400
Received: by wr-out-0506.google.com with SMTP id i21so311349wra
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 21:40:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi

i just want to have something like tcp layer sitting below inet layer.
so that i can directly offload everything to NIC
and i want it to be placed dynamically. so depending on the nic i can
offload the feature or can make it normal flow.
i.e. both layer should exist and normal functionality should not break.

this code is in af_inet.c

static struct inet_protosw inetsw_array[] =
{
       {
               .type =       SOCK_STREAM,
               .protocol =   IPPROTO_TCP,
               .prot =       &tcp_prot,
               .ops =        &inet_stream_ops,
               .capability = -1,
               .no_check =   0,
               .flags =      INET_PROTOSW_PERMANENT |
                             INET_PROTOSW_ICSK,
       },

       {
               .type =       SOCK_DGRAM,
               .protocol =   IPPROTO_UDP,
               .prot =       &udp_prot,
               .ops =        &inet_dgram_ops,
               .capability = -1,
               .no_check =   UDP_CSUM_DEFAULT,
               .flags =      INET_PROTOSW_PERMANENT,
      },


      {
              .type =       SOCK_RAW,
              .protocol =   IPPROTO_IP,        /* wild card */
              .prot =       &raw_prot,
              .ops =        &inet_sockraw_ops,
              .capability = CAP_NET_RAW,
              .no_check =   UDP_CSUM_DEFAULT,
              .flags =      INET_PROTOSW_REUSE,
      }
};

i was just going through the code i found that if i can regsiter above
kind of registration dynamically i will be able to do that.
i have tried to do that but since normal tcp registered this at boot
up time i am not able to unregister this dynamically

so is it possible to unregister tcp and register my protocol dynamically.

thanks
TEJ
