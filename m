From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip vrf: Add command name next to pid
Date: Fri, 14 Apr 2017 17:07:20 -0600
Message-ID: <7809495e-2fc5-fafe-6c39-8efd63ea006c@cumulusnetworks.com>
References: <1492048452-9052-1-git-send-email-dsa@cumulusnetworks.com>
 <20170414155737.24d3ce38@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33876 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754788AbdDNXHW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 19:07:22 -0400
Received: by mail-pg0-f42.google.com with SMTP id 21so48474162pgg.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 16:07:22 -0700 (PDT)
In-Reply-To: <20170414155737.24d3ce38@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/17 4:57 PM, Stephen Hemminger wrote:
> Overall, this looks like a good idea.
> 
>> +
>> +int get_comm(char *pid, char *comm, int len)
> 
> 
> Please use more glibc style function signature, like:
> 
> int get_comm(const char *pid, char *comm, size_t len)
> 
> And maybe even
> int get_command_name(pid_t pid, char *comm, size_t len)
> 

I'd pref to keep as char *. No sense converting from string to pid_t to
string. The vrf code is reading a cgroups file; the other potential user
is netns which is also reading pid from a file.
