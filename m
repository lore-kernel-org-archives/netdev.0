From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 11:42:53 +0100
Message-ID: <4B4317AD.1040302@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:52512 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232Ab0AEKm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 05:42:57 -0500
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o05Agsw4010951
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 10:42:54 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o05Ags2G1277994
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 10:42:54 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o05Ags0H005080
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 10:42:54 GMT
Received: from smtp.lab.toulouse-stg.fr.ibm.com (smtp.lab.toulouse-stg.fr.ibm.com [9.101.4.108])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id o05Agshk005073
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 10:42:54 GMT
Received: from mai-009101017029.toulouse-stg.fr.ibm.com (dhcp6.lab.toulouse-stg.fr.ibm.com [9.101.4.206])
	by smtp.lab.toulouse-stg.fr.ibm.com (Postfix) with ESMTP id 06AC82A8051
	for <netdev@vger.kernel.org>; Tue,  5 Jan 2010 11:42:54 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I noticed a change in the value returned by the getsockopt for the 
TCP_DEFER_ACCEPT option with a 2.6.32 kernel. The value retrieved with 
the getsockopt is different from the one specified with the setsockopt. 
Is it an expected behaviour ?

I saw there were  changes around the TCP_DEFER_ACCEPT option with the 
number of attempts converted to a number of seconds.

The following program is working fine with a 2.6.31 but fails with a 
2.6.32 kernel.

Thanks
  -- Daniel

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

int main(int argc, char *argv[])
{
    int val1 = 12, val2;
    socklen_t len = sizeof(val2);
    int fd;
   
    fd = socket(PF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        perror("socket");
        return -1;
    }
   
    if (setsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val1, sizeof(val1))) {
        perror("setsockopt");
        return -1;
    }
   
    if (getsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val2, &len)) {
        perror("getsockopt");
        return -1;
    }

    if (val1 != val2) {
        fprintf(stderr, "error %d != %d\n", val1, val2);
        return -1;
    }

    return 0;
}

